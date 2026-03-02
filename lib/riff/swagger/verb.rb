# frozen_string_literal: true

module Riff
  module Swagger
    class Verb

      SEQUEL_TYPE_MAP = {
        integer:  { "type" => "integer" },
        bignum:   { "type" => "integer" },
        string:   { "type" => "string" },
        text:     { "type" => "string" },
        boolean:  { "type" => "boolean" },
        datetime: { "type" => "string", "format" => "date-time" },
        date:     { "type" => "string", "format" => "date" },
        float:    { "type" => "number" },
        decimal:  { "type" => "number" },
        blob:     { "type" => "string" }
      }.freeze

      def initialize(tag, action_class, validator_class, context, path, verb, examples,
                     settings_class: nil, action_name: nil, base_path: "v1")
        @tag             = tag
        @action_class    = action_class
        @validator_class = validator_class
        @context         = context
        @path            = path.sub("/:", "/")
        @verb            = verb
        @base_path       = base_path
        @verb_examples   = verb_examples(examples)
        @settings_class  = settings_class
        @action_name     = action_name
      end

      def call
        {
          tags: [@tag],
          **query_params_spec.to_h,
          **request_body.to_h,
          responses: responses
        }
      end

      private

      def verb_examples(examples)
        path = ("/#{@base_path}" + @path).to_sym
        verb = @verb.downcase.to_sym
        examples[path].to_h[verb].to_a.presence
      end

      # --- Query parameters (GET index only) ---

      def query_params_spec
        return unless @verb == "GET" && @action_name == :index && @settings_class

        fields = @settings_class.index_fields
        return unless fields

        db_schema = model_db_schema
        params    = fields.map { |f| field_param(f, db_schema) }
        params << pagination_param("_page")
        params << pagination_param("_limit")
        { parameters: params }
      end

      def field_param(field, db_schema)
        col       = db_schema[field]
        type_info = SEQUEL_TYPE_MAP[col&.dig(:type)] || { "type" => "string" }
        { name: field.to_s, in: "query", required: false, schema: type_info }
      end

      def pagination_param(name)
        { name: name, in: "query", required: false, schema: { "type" => "integer" } }
      end

      def request_body
        schema = build_schema
        return if schema.blank? || schema["properties"].blank?

        {
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: schema,
                **request_examples.to_h
              }
            }
          }
        }
      end

      def responses
        base = {
          "200": { description: "Successful operation", **response_200_content.to_h },
          "401": { description: "Authentication failure" },
          "403": { description: "Authorization failure" },
          "404": { description: "Resource not found" },
          "422": { description: "Invalid parameters" }
        }
        base.map do |k, v|
          # Skip content() for 200 — response_200_content already handles schema + examples
          extras = k == :"200" ? {} : content(k.to_s.to_i)
          [k, v.merge(extras)]
        end.to_h
      end

      def response_200_content
        schema   = build_response_schema
        examples = find_examples(200, :response)

        parts = {}
        parts[:schema]   = schema   if schema
        parts[:examples] = examples if examples.present?
        return if parts.empty?

        { content: { "application/json": parts } }
      end

      def build_response_schema
        return unless @settings_class

        fields = case @action_name
                 when :index then @settings_class.index_fields
                 when :show  then @settings_class.show_fields
                 end
        return unless fields
        return unless @settings_class.model

        db_schema   = model_db_schema
        item_schema = item_schema_from_fields(fields, db_schema)

        if @action_name == :index
          {
            "type"       => "object",
            "properties" => {
              "success" => { "type" => "boolean" },
              "total"   => { "type" => "integer" },
              "data"    => { "type" => "array", "items" => item_schema }
            }
          }
        else
          {
            "type"       => "object",
            "properties" => {
              "success" => { "type" => "boolean" },
              "data"    => item_schema
            }
          }
        end
      end

      def item_schema_from_fields(fields, db_schema)
        properties = fields.to_h do |field|
          col       = db_schema[field]
          type_info = SEQUEL_TYPE_MAP[col&.dig(:type)] || { "type" => "string" }
          [field.to_s, type_info]
        end
        { "type" => "object", "properties" => properties }
      end

      def model_db_schema
        @model_db_schema ||= @settings_class.model&.db_schema || {}
      rescue StandardError
        {}
      end

      def content(code)
        examples = find_examples(code, :response)
        return {} if examples.blank?

        {
          content: {
            "application/json": {
              examples: examples
            }
          }
        }
      end

      def find_examples(code, type)
        return unless @verb_examples

        i = 0
        added = Set.new
        @verb_examples.filter_map do |example|
          next if type == :response && example[type][:status] != code
          next unless example[type] && example[type][:body].present?

          body = example[type][:body]
          next unless added.add?(body)

          value =
            begin
              Oj.load(body)
            rescue EncodingError
              next
            end

          next if value.blank?

          {
            "Example-#{i += 1}": {
              value: value
            }
          }
        end.inject({}, :merge)
      end

      def build_schema
        return @build_schema if defined?(@build_schema)

        @build_schema = begin
          return unless contract_class

          require("dry/swagger")
          parser = Dry::Swagger::ContractParser.new
          parser.call(contract_class)
          normalize_schema(parser.to_swagger)
        rescue Dry::Swagger::Errors::MissingHashSchemaError, StandardError => e
          raise unless e.message.include?("Could not generate documentation for field")

          warn("Swagger: skipping schema for #{@path} #{@verb} — #{e.message.lines.first.strip}")
          nil
        end
      end

      def contract_class
        return unless @validator_class

        @contract_class ||=
          case @validator_class.superclass.to_s
          when "Riff::Validator"
            @validator_class
          when "Riff::DynamicValidator"
            @validator_class.new.klass(@context)
          else
            raise("Validator superclass must be one of Riff::Validator or Riff::DynamicValidator, but it is #{@validator_class.superclass}")
          end
      end

      def normalize_schema(schema)
        schema = schema.deep_stringify_keys
        schema.deep_merge!(schema) do |k, v|
          if k.to_sym == :type && v.is_a?(Symbol)
            v.to_s
          else
            v
          end
        end
        schema.delete("required") if schema["required"].blank?
        schema
      end

      def request_examples
        examples = find_examples(nil, :request)
        { examples: examples } if examples.present?
      end
    end
  end
end

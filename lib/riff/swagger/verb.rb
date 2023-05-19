module Riff
  module Swagger
    class Verb
      def initialize(tag, action_class, validator_class, context, path, verb, examples)
        @tag = tag
        @action_class = action_class
        @validator_class = validator_class
        @context = context
        @path = path
        @verb = verb
        @verb_examples = verb_examples(examples)
      end

      def call
        {
          tags: [@tag],
          **request_body.to_h,
          responses: responses,
        }
      end

      private

      def verb_examples(examples)
        path = ('/v1' + @path).to_sym
        verb = @verb.downcase.to_sym
        examples[path].to_h[verb].to_a.presence
      end

      def request_body
        return unless schema

        {
          requestBody: {
            required: true,
            content: {
              'application/json': {
                schema: schema
              }
            }
          }
        }
      end

      def responses
        {
          '200': {
            description: 'Successful operation'
          },
          '401': {
            description: 'Authentication failure'
          },
          '403': {
            description: 'Authorization failure'
          },
          '404': {
            description: 'Resource not found'
          },
          '422': {
            description: 'Invalid parameters'
          }
        }.map do |k, v|
          [k, v.merge(content(k.to_s.to_i))]
        end.to_h
      end

      def content(code)
        examples = find_examples(code)
        return {} if examples.blank?

        {
          content: {
            'application/json': {
              examples: examples
            }
          }
        }
      end

      def find_examples(code)
        return unless @verb_examples

        i = 0
        @verb_examples.filter_map do |example|
          next unless example[:response][:status] == code

          {
            "Example-#{i += 1}": {
              value: Oj.load(example[:response][:body])
            }
          }
        end.inject(&:merge)
      end

      def schema
        return unless contract_class

        require 'dry/swagger'
        parser = Dry::Swagger::ContractParser.new
        parser.call(contract_class)
        brush_schema(parser.to_swagger)
      end

      def contract_class
        return unless @validator_class

        @contract_class ||= begin
          case @validator_class.superclass.to_s
          when 'Riff::Validator'
            @validator_class
          when 'Riff::DynamicValidator'
            @validator_class.new.klass(@context)
          else
            raise "Validator superclass must be one of Riff::Validator or Riff::DynamicValidator, but it is #{@validator_class.superclass}"
          end
        end
      end

      def brush_schema(schema)
        schema = schema.deep_stringify_keys
        schema.deep_merge!(schema) do |k, v|
          if k.to_sym == :type && v.is_a?(Symbol)
            v.to_s 
          else
            v
          end
        end
        schema.delete('required') if schema['required'].blank?
        schema
      end
    end
  end
end

module Riff
  module Swagger
    class Verb
      def initialize(tag, action_class, validator_class, context)
        @tag = tag
        @action_class = action_class
        @validator_class = validator_class
        @context = context
      end

      def call
        {
          tags: [@tag],
          **request_body.to_h,
          responses: responses,
        }
      end

      private

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
            description: 'Successful operation',
            content: {
              'application/json': {
                # schema: {
                #   '$ref': '#/components/schemas/Message'          
                # }
              }
            }
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
        }
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
            raise "Validator subclass must be one of Riff::Validator or Riff::DynamicValidator, but it is #{@validator_class.superclass}"
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

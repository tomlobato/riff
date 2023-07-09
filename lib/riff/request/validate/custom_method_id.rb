# frozen_string_literal: true

module Riff
  module Request
    class Validate
      class CustomMethodId
        ID_PRESENCE_VALUES = %i[required denied optional].freeze
        DEFAULT_ID_PRESENCE = :denied
      
        def initialize(context)
          @context = context
        end

        def call
          validate_custom_method_id_presence!
        end

        private

        attr_reader :context

        def validate_custom_method_id_presence!
          unless id_presence.in?(ID_PRESENCE_VALUES)
            raise(Riff::Exceptions::InternalServerError, "Constant WITH_ID must be: #{ID_PRESENCE_VALUES.join(", ")}.")
          end
        
          case id_presence
          when :required
            unless context.id
              Riff::Exceptions::InvalidParameters.raise!(field_errors: { id: "id in the url path is required" })
            end
          when :denied
            if context.id
              Riff::Exceptions::InvalidParameters.raise!(field_errors: { id: "This custom method must not have an id in the url path" })
            end
          when :optional
            # do nothing
          end
        end
        
        def id_presence
          return @id_presence if defined?(@id_presence)
        
          @id_presence = "#{context.action_class}::ID_PRESENCE".constantize
        rescue NameError
          @id_presence = DEFAULT_ID_PRESENCE
        end
      end
    end
  end
end

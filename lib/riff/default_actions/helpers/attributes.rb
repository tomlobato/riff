# frozen_string_literal: true

module Riff
  module DefaultActions
    module Helpers
      module Attributes
        private

        def attributes
          return params unless scope.present?

          validate_scope!
          params.merge(scope)
        end

        def validate_scope!
          invalid_params = {}
          params.slice(*@scope.keys).each do |key, param_value|
            next if param_value.blank?
            next if param_value == scope[key]

            invalid_params[key] = param_value
          end
          raise(Exceptions::InvalidParameters, invalid_params.to_json) if invalid_params.present?
        end
      end
    end
  end
end

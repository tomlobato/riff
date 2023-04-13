# frozen_string_literal: true

module Riff
  module Actions
    module Helpers
      module Attributes
        private

        def attributes
          return params unless scope.present?

          validate_scope!
          atts = params.merge(scope)
          atts
            .slice(*only_keys(atts))
            .merge(extra_attributes.to_h)
        end

        def validate_scope!
          invalid_params = {}
          params.slice(*scope.keys).each do |key, param_value|
            next if param_value.blank?
            next if param_value == scope[key]

            invalid_params[key] = param_value
          end
          raise(Exceptions::InvalidParameters, invalid_params.to_json) if invalid_params.present?
        end
  
        def only_keys(atts)
          atts.keys - ignore_attributes.to_a.map(&:to_sym)
        end

        def extra_attributes
          # may implement
        end
  
        def ignore_attributes
          # may implement
        end
      end
    end
  end
end

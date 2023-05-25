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
          atts.slice(*only_keys(atts)).merge(extra_attributes.to_h)
        end

        def validate_scope!
          invalid_params = {}
          params.slice(*scope.keys).each do |key, param_value|
            next if param_value.blank?
            # @context.scope is generated in authorization handler,
            # while validation/coercing wans`t run yet.
            # @context.params here have the validated/coerced values.
            # How to compare both if both may be differente even if are valid?
            # By now its handled with .to_s, but some other solution must be found
            # to handle this comparation accordingly
            next if param_value.to_s == scope[key].to_s

            invalid_params[key] = param_value
          end
          Exceptions::InvalidParameters.raise!(field_errors: invalid_params) if invalid_params.present?
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

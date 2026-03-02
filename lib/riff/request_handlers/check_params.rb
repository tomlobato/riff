# frozen_string_literal: true

module Riff
  module RequestHandlers
    class CheckParams < Base
      private

      def setup
        @action_validator = action_validator
      end

      def action_validator
        @context.action.camelize.to_sym
      end

      def class_nodes
        [Conf.resources_base_module, module_name, :Validators, @action_validator]
      end

      def run
        return unless @action_validator

        validator = Validate.new(
          class_nodes,
          @context.raw_params,
          allow_empty_params: allow_empty_params,
          context: @context
        )
        result = validator.call
        if result
          if fallback_passthrough?(validator)
            @context.params = @context.raw_params.merge(result)
          else
            check_excess_params!(result)
            @context.params = result
          end
        end
        nil
      end

      def allow_empty_params
        @context.action != "update"
      end

      def check_excess_params!(result)
        excess_params = @context.raw_params.keys - result.keys
        raise(Riff::Exceptions::InvalidParameters, { excess_params: excess_params }.to_json) unless excess_params.empty?
      end

      def fallback_passthrough?(validator)
        Conf.allow_excess_params_on_fallback && validator.used_fallback
      end
    end
  end
end

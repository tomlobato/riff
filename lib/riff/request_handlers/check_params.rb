module Riff
  module RequestHandlers
    class CheckParams < Base
      private

      def setup
        @action_validator = select_action_validator
        @validator_class = select_validator_class if @action_validator
      end

      def select_action_validator
        :SaveValidator if @context.action.in?(%w(create update))
      end

      def select_validator_class
        Util.const_get(validator_class_nodes, anchor: true)
      end

      def validator_class_nodes
        [:Actions, model_name, @action_validator]
      end

      def run
        return unless @validator_class

        result = @validator_class.new.call(@context.params)
        thrown_error(result.errors) if result.failure?
      end
      
      def thrown_error(errors)
        msg = errors.to_h.to_json
        raise(Exceptions::InvalidParams.new(msg))
      end
    end
  end
end

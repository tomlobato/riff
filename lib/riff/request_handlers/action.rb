module Riff
  module RequestHandlers
    class Action < Base
      private

      def run
        action_class.new(@context).call
      end

      private

      def action_class
        action_class_name = find_action_class_name
        Util.const_get("Actions::#{@context.model_name}::#{action_class_name}") || 
        Util.const_get("DefaultActions::#{action_class_name}")
      end

      def find_action_class_name
        @context.action.classify
      end
    end
  end
end

module Riff
  module RequestHandlers
    class Action < Base
      private

      def run
        @action_class_name = find_action_class_name
        action_class.new(@context).call
      end

      private

      def action_class
        Util.const_get(custom_action) || Util.const_get(default_action)
      end

      def find_action_class_name
        @context.action.classify
      end

      def custom_action
        "::Actions::#{@context.model_name}::#{@action_class_name}"
      end

      def default_action
        "Riff::DefaultActions::#{@action_class_name}"
      end
    end
  end
end

module Riff
  module RequestHandlers
    class Action < Base
      private

      def run
        action_class.new(@context).call
      end

      private

      def action_class
        raise(Riff::Exceptions::ActionNotFound) unless enabled?

        Util.const_get(custom_action, anchor: true) || Util.const_get(default_action) || raise(Riff::Exceptions::ActionNotFound)
      end

      def custom_action
        [:Actions, model_name, action_class_name]
      end

      def default_action
        [:Riff, :DefaultActions, action_class_name]
      end

      def enabled?
        return true if @context.is_custom_method

        settings = Util.const_get(:Actions, model_name, :ActionSettings, anchor: true)&.new
        !settings || settings.send("#{action}?")
      end
    end
  end
end

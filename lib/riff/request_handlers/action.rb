module Riff
  module RequestHandlers
    class Action < Base
      private

      def run
        action_class.new(@context).call
      end

      private

      def action_class
        raise(action_not_found) unless enabled?

        Util.const_get(custom_action, anchor: true) || Util.const_get(default_action) || raise(action_not_found)
      end

      def action_not_found
        Riff::Exceptions::ActionNotFound.create(path, request_method)
      end
  
      def custom_action
        [:Actions, model_name, action_class_name]
      end

      def default_action
        [:Riff, :DefaultActions, action_class_name]
      end

      def enabled?
        return true if @context.is_custom_method

        settings = Util.const_get(settings_class_path, anchor: true)&.new
        !settings || settings.send("#{action}?")
      end

      def settings_class_path
        [:Actions, model_name, :ActionSettings]
      end
    end
  end
end

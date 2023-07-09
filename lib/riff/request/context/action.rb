# frozen_string_literal: true

module Riff
  module Request
    class Context
      module Action
        ACTION_MAP = {
          with_id: { "GET" => "show", "DELETE" => "delete", "PATCH" => "update" },
          without_id: { "GET" => "index", "POST" => "create" }
        }.freeze
  
        private_constant :ACTION_MAP
  
        def action
          @action ||= (custom_method || action_map[request_method])
        end

        # TODO: check need if camelize or classify if
        def action_class_name
          @action_class_name ||= action.__send__(custom_method ? :camelize : :classify)
        end

        def action_class
          @action_class ||= (custom_action_class || Util.const_get(default_action_class_path))
        end
  
        def custom_action_class
          @custom_action_class ||= Util.const_get(custom_action_class_path, anchor: true)
        end

        private

        def action_map
          ACTION_MAP[id ? :with_id : :without_id]
        end

        def default_action_class_path
          [:Riff, :Actions, action_class_name]
        end

        def custom_action_class_path
          [Conf.resources_base_module, module_name, :Actions, action_class_name]
        end
      end
    end
  end
end

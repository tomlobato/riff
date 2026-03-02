# frozen_string_literal: true

module Riff
  module Swagger
    class Read
      ACTION_VERB_MAP = { create: "POST", show: "GET", index: "GET", update: "PATCH", delete: "DELETE" }.freeze
      REST_ID_ACTIONS = %i[show update delete].freeze
      STANDARD_ACTIONS = ACTION_VERB_MAP.keys.freeze

      def initialize
        @res_mod = Conf.resources_base_module
        @res_remap = Riff::Conf.resource_remap.invert
        @paths = {}
      end

      def call
        @res_mod.constants.each do |model_name|
          handle_model(model_name)
        end
        sort(@paths)
      end

      private

      def sort(paths)
        paths.sort.to_h.transform_values { |verbs| verbs.sort.to_h }
      end

      def handle_model(model_name)
        handle_standard_actions(model_name)
        handle_custom_actions(model_name)
      end

      # Discover standard CRUD paths from Enable (works even with no Actions/ dir)
      def handle_standard_actions(model_name)
        enable = enable_instance(model_name)
        return unless enable

        settings = settings_instance(model_name)

        STANDARD_ACTIONS.each do |action_name|
          next unless enable.public_send(:"#{action_name}?")

          verb  = ACTION_VERB_MAP[action_name]
          node1 = find_node1(model_name)
          node2 = REST_ID_ACTIONS.include?(action_name) ? "{id}" : ""
          path  = build_path(node1, node2)

          @paths[path] ||= {}
          @paths[path][verb] = {
            tag:             build_tag(node1),
            action_class:    nil,
            validator_class: validator_class(model_name, action_name),
            settings_class:  settings,
            action_name:     action_name
          }
        end
      end

      # Discover paths from explicit Actions::* class files (overwrites standard entries)
      def handle_custom_actions(model_name)
        actions_mod = "#{@res_mod}::#{model_name}::Actions".constantize
        actions_mod.constants.each do |action_name|
          handle_action(model_name, action_name)
        end
      rescue NameError
        nil
      end

      def handle_action(model_name, action_name)
        action_class = Util.const_get(@res_mod, model_name, :Actions, action_name, anchor: true)
        save_custom(action_class, model_name, action_name) if action_class.instance_of?(Class)
      end

      def build_tag(node1)
        node1.split("_").map(&:capitalize).join(" ")
      end

      def build_path(node1, node2)
        "/" + [node1, node2].select(&:present?).join("/")
      end

      def save_custom(action_class, model_name, action_name)
        node1, node2, verb = build_action_data(model_name, action_name, action_class)
        path = build_path(node1, node2)

        @paths[path] ||= {}
        @paths[path][verb] = {
          tag:             build_tag(node1),
          action_class:    action_class,
          validator_class: validator_class(model_name, action_name),
          settings_class:  settings_instance(model_name),
          action_name:     action_name.to_s.underscore.to_sym
        }
      end

      def build_action_data(model_name, action_name, action_class)
        node1 = find_node1(model_name)
        node2 = find_node2(action_name, action_class)
        verb = find_verb(action_name, action_class)
        [node1, node2, verb]
      end

      def validator_class(model_name, action_name)
        "#{@res_mod}::#{model_name}::Validators::#{action_name}".constantize
      rescue NameError
        Riff::FallbackValidator
      end

      def enable_instance(model_name)
        "#{@res_mod}::#{model_name}::Enable".constantize.new
      rescue NameError
        # Fall back to Riff::Enable defaults if resource has Settings but no Enable
        begin
          "#{@res_mod}::#{model_name}::Settings".constantize
          Riff::Enable.new
        rescue NameError
          nil
        end
      end

      def settings_instance(model_name)
        "#{@res_mod}::#{model_name}::Settings".constantize.new
      rescue NameError
        nil
      end

      def find_node1(model_name)
        node1 = model_name.to_s.underscore.to_sym
        node1 = @res_remap[node1] if @res_remap[node1]
        node1.to_s
      end

      def find_verb(action_name, action_class)
        node2 = action_name.to_s.underscore
        node2.to_sym.in?(ACTION_VERB_MAP.keys) ? ACTION_VERB_MAP[node2.to_sym] : custom_action_verb(action_class)
      end

      def custom_action_verb(custom_action_class)
        "#{custom_action_class}::VERB".constantize
      rescue NameError
        Riff::HttpVerbs::POST
      end

      def find_node2(action_name, action_class)
        node2 = action_name.to_s.underscore
        if node2.to_sym.in?(ACTION_VERB_MAP.keys)
          node2 = node2.to_sym.in?(REST_ID_ACTIONS) ? "{id}" : ""
        else
          id_presence = defined?(action_class::ID_PRESENCE) ? action_class::ID_PRESENCE : :denied
          case id_presence
          when :required
            node2.prepend("{id}:")
          when :optional
            node2.prepend("{optional_id}:")
          when :denied
            # no change
          end
        end
        node2
      end
    end
  end
end

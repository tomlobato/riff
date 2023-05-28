# frozen_string_literal: true

module Riff
  module Swagger
    class Read
      ACTION_VERB_MAP = { create: "POST", show: "GET", index: "GET", update: "PATCH", delete: "DELETE" }.freeze
      REST_ID_ACTIONS = %i[show update delete].freeze

      def initialize
        @res_mod = Conf.resources_base_module
        @res_remap = Riff::Conf.resource_remap.invert
        @model_less_res = Riff::Conf.model_less_resources
        @paths = {}
      end

      def call
        @res_mod.constants.each do |model_name|
          handle_model(model_name)
        end
        # puts "@paths.keys.size=#{@paths.keys.size}"
        sort(@paths)
      end

      private

      def sort(paths)
        paths.sort.to_h.each do |_path, verbs|
          verbs.sort.to_h.each do |verb, data|
          end
        end
      end

      def handle_model(model_name)
        actions_mod = "#{@res_mod}::#{model_name}::Actions".constantize
        actions_mod.constants.each do |action_name|
          handle_action(model_name, action_name)
        end
      end

      def handle_action(model_name, action_name)
        action_class = Util.const_get(@res_mod, model_name, :Actions, action_name, anchor: true)
        save(action_class, model_name, action_name) if action_class.instance_of?(Class)
      end

      def build_tag(node1)
        node1.split("_").map(&:capitalize).join(" ")
      end

      def build_path(node1, node2)
        "/" + [node1, node2].select(&:present?).join("/")
      end

      def save(action_class, model_name, action_name)
        node1, node2, verb = build_action_data(model_name, action_name, action_class)
        path = build_path(node1, node2)

        @paths[path] ||= {}
        @paths[path][verb] = {
          tag: build_tag(node1),
          action_class: action_class,
          validator_class: validator_class(model_name, action_name)
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

      def find_node1(model_name)
        node1 = model_name.to_s.underscore
        node1 = node1.pluralize unless @model_less_res.include?(node1.to_sym)
        node1 = node1.to_sym
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
          id_presence = defined?(action_class::ID_PRESENCE) ? action_class::ID_PRESENCE : Request::ActionProcessor::DEFAULT_ID_PRESENCE
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

# frozen_string_literal: true

module Riff
  module Swagger
    class Read
      ACTION_VERB_MAP = { create: 'POST', show: 'GET', index: 'GET', update: 'PATCH', delete: 'DELETE' }.freeze

      def initialize(base_path)
        @base_path = base_path
        @res_mod = Conf.get(:resources_base_module)
        @res_remap = Riff::Conf.get(:resource_remap).invert
        @model_less_res = Riff::Conf.get(:model_less_resources)
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
        paths.sort.to_h.each do |path, verbs|
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
        action_class = "#{@res_mod}::#{model_name}::Actions::#{action_name}".constantize
        return unless action_class.instance_of?(Class)

        node1 = find_node1(model_name)
        node2 = find_node2(action_name, action_class)
        verb = find_verb(action_name, action_class)
        path = '/' + [node1, node2].select(&:present?).join('/')

        @paths[path] ||= {}
        @paths[path][verb] = {
          tag: node1.split('_').map(&:capitalize).join(' '),
          action_class: action_class,
          validator_class: validator_class(model_name, action_name)
        }
      end

      def validator_class(model_name, action_name)
        "#{@res_mod}::#{model_name}::Validators::#{action_name}".constantize
      rescue NameError
        nil
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
        if node2.in?(%w[create show index update delete])
          verb = ACTION_VERB_MAP[node2.to_sym]
        else
          verb = action_class::VERB.to_s.upcase
        end
        verb
      end

      def find_node2(action_name, action_class)
        node2 = action_name.to_s.underscore
        if node2.in?(%w[create show index update delete])
          if node2.in?(%w[show update delete])
            node2 = "{id}" 
          else
            node2 = ""
          end
        else
          case action_class::ID_PRESENCE
          when :required
            node2.prepend("{id}:") 
          when :optional
            node2.prepend("{id}?:") 
          when :denied
            # node changes
          end
        end
        node2
      end
    end
  end
end

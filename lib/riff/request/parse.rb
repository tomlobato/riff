# frozen_string_literal: true

module Riff
  module Request
    class Parse
      ACTION_MAP = {
        with_id: { "GET" => "show", "DELETE" => "delete", "PATCH" => "update" },
        without_id: { "GET" => "index", "POST" => "create" }
      }.freeze

      private_constant :ACTION_MAP

      def initialize(request)
        @path = request.path
        @request_method = request_method(request.request_method)
        @params = request.params.deep_symbolize_keys
        @headers = request.headers
        @url = request.url
        @remote_ip = remote_ip
        setup
      end

      def call
        return unless @node1

        validate_path!
        context = Context.new(basic_context.merge(extra_context))
        custom_context(context).to_h.each { |k, v| context.set(k, v) }
        context
      end

      private

      def module_name
        @module_name ||= @node1.camelize
      end

      def settings_class_path
        [Conf.resources_base_module, module_name, :Settings]
      end

      def settings
        @settings ||= (Util.const_get(settings_class_path, anchor: true)&.new || Settings.new)
      end

      def model_name
        @model_name ||= (settings.model&.to_s || default_model_name) unless @model_less
      end

      def default_model_name
        @node1.singularize.classify
      end

      def model_class
        Util.const_get("::#{model_name}") unless @model_less
      end

      def custom_context(context)
        return unless (custom_context_class = Conf.custom_context_class)

        custom_context_class.new(context).call
      end

      def setup
        @node1, @node2, @node3 = @path_nodes = path_nodes
        return unless @node1

        @resource = find_resource
        @model_less = model_less?
        @id, @custom_method = parse_node2
        @action = find_action
      end

      def parse_node2
        node = @node2.to_s.presence
        return unless node
        return node.split(":", 2).map(&:presence) if node.index(":")

        case Conf.no_colon_mode
        when :id
          [node, nil]
        when :custom_method
          [nil, node]
        when :id_if_digits
          node.match?(Constants::ONLY_DIGITS) ? [node, nil] : [nil, node]
        when :id_if_uuid
          node.match?(Constants::UUID) ? [node, nil] : [nil, node]
        when :id_if_digits_or_uuid
          node.match?(Constants::ONLY_DIGITS) || node.match?(Constants::UUID) ? [node, nil] : [nil, node]
        else
          raise(StandardError, "Unknown no_colon_mode: #{Conf.no_colon_mode}")
        end
      end

      def basic_context
        {
          request_method: @request_method,
          headers: @headers,
          params: @params,
          path: @path,
          url: @url,
          remote_ip: @remote_ip
        }
      end

      def extra_context
        {
          settings: settings,
          module_name: module_name,
          resource: @resource,
          id: @id,
          model_name: model_name,
          model_less: @model_less,
          model_class: model_class,
          action: @action,
          action_class_name: action_class_name,
          is_custom_method: !@custom_method.nil?
        }
      end

      def request_method(raw_request_method)
        Object.const_get("Riff::HttpVerbs::#{raw_request_method.upcase}")
      rescue NameError
        raise(action_not_found(request_method: raw_request_method))
      end

      def action_class_name
        @custom_method ? @action.camelize : @action.classify
      end

      def model_less?
        Riff::Conf.model_less_resources.include?(@resource.to_sym)
      end

      def find_resource
        Riff::Conf.resource_remap[@node1.to_sym]&.to_s || @node1
      end

      def find_action
        @custom_method || action_map[@request_method] || raise(action_not_found)
      end

      def action_not_found(request_method: nil)
        Riff::Exceptions::ActionNotFound.create(@path, request_method || @request_method)
      end

      def action_map
        ACTION_MAP[@id ? :with_id : :without_id]
      end

      def path_nodes
        @path.split("/").reject(&:blank?)[1..]
      end

      def validate_path!
        raise(Riff::Exceptions::OutOfBoundsPathNodes) unless @path_nodes.size.between?(1, 2)
      end

      def remote_ip
        RemoteIp.new(@headers).call
      end
    end
  end
end

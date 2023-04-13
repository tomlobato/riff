# frozen_string_literal: true

module Riff
  module Request
    class Parse
      def initialize(request)
        @path = request.path
        @request_method = request.request_method
        @params = request.params.deep_symbolize_keys
        @headers = request.headers
        @url = request.url
        setup
        # pp self
      end

      def call
        validate_path!
        Context.new(basic_context.merge(extra_context))
      end

      private

      def basic_context
        {
          request_method: @request_method,
          headers: @headers,
          params: @params,
          path: @path,
          url: @url
        }
      end

      def extra_context
        {
          resource: @resource,
          id: @id,
          model_name: @resource.classify,
          model_class: model_class,
          action: @action,
          action_class_name: action_class_name,
          is_custom_method: !@custom_method.nil?
        }
      end

      def action_class_name
        @custom_method ? @action.camelize : @action.classify
      end

      def model_class
        Util.const_get("::#{@resource.classify}")
      end

      def setup
        @node1, @node2, @node3 = @path_nodes = path_nodes
        @resource = find_resource(@node1)
        @id, @custom_method = @node2.to_s.split(":", 2)
        @action = find_action
      end

      def find_resource(node1)
        return node1.singularize unless resource_remap

        (resource_remap[node1] || node1).singularize
      end

      def resource_remap
        return @resource_remap if defined?(@resource_remap)

        @resource_remap = Riff::Conf.get(:resource_remap)&.transform_keys(&:to_s)&.transform_values(&:to_s)
      end

      def find_action
        @custom_method || action_map[@request_method.upcase.to_sym] || raise(action_not_found)
      end

      def action_not_found
        Riff::Exceptions::ActionNotFound.create(@path, @request_method)
      end

      def action_map
        if @id
          { GET: "show", DELETE: "delete", PATCH: "update" }
        else
          { GET: "index", POST: "create" }
        end
      end

      def path_nodes
        @path.split("/").reject(&:blank?)[1..]
      end

      def validate_path!
        raise(Riff::Exceptions::OutOfBoundsPathNodes) unless @path_nodes.size.between?(1, 2)
      end
    end
  end
end

# frozen_string_literal: true

module Riff
  module Request
    class Parse
      def initialize(request)
        @path = request.path
        @request_method = request.request_method
        @params = request.params.symbolize_keys
        @headers = request.headers
        @url = request.url
        setup
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
          action: @action,
          action_class_name: @action.classify,
          is_custom_method: !@custom_method.nil?
        }
      end

      def setup
        @node1, @node2, @node3 = @path_nodes = path_nodes
        @resource = @node1.singularize
        @id, @custom_method = @node2.to_s.split(":")
        @action = find_action
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

module Riff
  class ParseRequest
    def initialize(request)
      @path = request.path
      @request_method = request.request_method
      @params = request.params
      @headers = request.headers
      @url = request.url
      setup
    end

    def call
      validate_path!
      RequestContext.new(
        resource: @resource,
        id: @id,
        params: @params,
        model_name: @resource.classify,
        action: @action,
        action_class_name: @action.classify,
        is_custom_method: !!@custom_method,
        headers: @headers,
        request_method: @request_method,
        path: @path,
        url: @url,
      )
    end

    private

    def setup
      @node1, @node2, @node3 = @path_nodes = path_nodes
      @id, @custom_method = parse_id_and_custom_method
      @resource = @node1.singularize
      @action = find_action
    end

    def find_action
      @custom_method || action_map[@request_method.upcase] || raise(action_not_found)
    end

    def action_not_found
      Riff::Exceptions::ActionNotFound.create(path, request_method)
    end

    def action_map
      if @id
        {'GET' => 'show', 'DELETE' => 'delete', 'PATCH' => 'update'}
      else
        {'GET' => 'index', 'POST' => 'create'}
      end
    end

    def path_nodes
      @path
        .split('/')
        .reject(&:blank?)[1..-1]      
    end

    def validate_path!
      raise(Riff::Exceptions::OutOfBoundsPathNodes) unless @path_nodes.size.between?(1, 3)
    end

    def parse_id_and_custom_method
      if Util.is_id?(@node2)
        [@node2, @node3]
      else
        raise(Riff::Exceptions::InvalidRequestPath) if @node3.present?

        [nil, @node2]
      end
    end
  end
end

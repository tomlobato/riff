module Riff
  class ParseRequest
    def initialize(request)
      @path = request.path
      @request_method = request.request_method
      @params = request.params
      @node1, @node2, @node3 = @path_nodes = path_nodes
      @id, @custom_method = parse_id_and_custom_method
      @resource = @node1.singularize
      @action = find_action
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
      )
    end

    private

    def find_action
      return @custom_method if @custom_method

      action_map =
        if @id
          {'GET' => 'show', 'DELETE' => 'delete', 'PATCH' => 'update'}
        else
          {'GET' => 'index', 'POST' => 'create'}
        end
        
      action_map[@request_method.upcase] || raise(Riff::Exceptions::ActionNotFound)
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

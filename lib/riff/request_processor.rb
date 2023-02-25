module Riff
  class RequestProcessor
    def initialize(path, request_method, params)
      @path = path
      @request_method = request_method
      @params = params
      @node1, @node2, @node3 = @path_nodes = path_nodes
      @id, @custom_method = parse_id_and_custom_method
    end

    def call
      validate_path!
      RequestChain.new(context).call
    end

    private

    def context
      resource = @node1.singularize
      RequestContext.new(
        resource: resource,
        id: @id,
        action: action,
        params: @params,
        model_name: resource.classify,
      )
    end

    def action
      return @custom_method if @custom_method

      action_map =
        if @id
          {'GET' => 'show', 'DELETE' => 'delete', 'PATCH' => 'update'}
        else
          {'GET' => 'list', 'POST' => 'create'}
        end
        
      action_map[@request_method.upcase] || raise(Exceptions::UnknownRequestAction)
    end

    def path_nodes
      @path
        .split('/')
        .reject(&:blank?)[1..-1]      
    end

    def validate_path!
      raise(Exceptions::OutOfBoundsPathNodes) unless @path_nodes.size.between?(1, 3)
    end

    def parse_id_and_custom_method
      if @node2 =~ /^\d+$/
        [@node2, @node3]
      else
        raise(Exceptions::InvalidRequestPath) if @node3.present?

        [nil, @node2]
      end
    end
  end
end

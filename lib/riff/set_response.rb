module Riff
  class SetResponse
    def initialize(response, result)
      @response = response
      @result = result
    end

    def call
      content_type
      headers
      status
      body
    end
    
    private
    
    def content_type
      @response['Content-Type'] = @result.content_type if @result.content_type
    end
    
    def headers
      @result.headers.each { |k, v| @response[k] = v } if @result.headers
    end

    def status
      @response.status = @result.status if @result.status
    end

    def body
      prepare_body(@result.body) if @result.body
    end

    def prepare_body(raw)
      case raw
      when String, Nil
        raw
      when Array, Hash
        Oj.dump(raw)
      else
        raise(Riff::Exceptions::InvalidResponseBody)
      end
    end
  end
end

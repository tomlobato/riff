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
      body(@result.body)
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

    def body(raw)
      case raw
      when String
        raw
      when NilClass
        ''
      when Array, Hash
        Oj.dump(raw)
      else
        raise(Riff::Exceptions::InvalidResponseBody.new("Unhandled body class '#{raw.class}'"))
      end
    end
  end
end

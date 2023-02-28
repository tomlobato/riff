module Riff
  class SessionProcessor
    def initialize(request, response, type)
      @request = request
      @response = response
      @type = type
    end

    def call
      SetResponse.new(@response, sign_in_out).call
    end

    private

    def sign_in_out
      case @type
      when 'sign_in'
        sign_in
      when 'sign_out'
        sign_out
        Result.new
      else
        raise(invalid_request_path)
      end
    rescue StandardError => e
      desc, status = HandleError.new(e).call
      Result.new(desc, status: status)
    end

    def invalid_request_path
      Exceptions::InvalidRequestPath.new("'#{@type}' is not a valid session action")
    end

    def sign_in
      OpenSession.new(@request.params).call
    end

    def sign_out
      CloseSession.new(@request.headers).call
    end
  end
end

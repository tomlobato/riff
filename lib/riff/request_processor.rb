module Riff
  class RequestProcessor
    def initialize(request, response)
      @request = request
      @response = response
    end

    def call
      SetResponse.new(@response, call_chain).call
    end

    private

    def call_chain
      RequestChain.new(context).call
    rescue StandardError => e
      desc, status = HandleError.new(e).call
      Result.new(desc, status: status)
    end

    def context
      ParseRequest.new(@request).call
    end
  end
end

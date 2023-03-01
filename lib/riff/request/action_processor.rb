module Riff
  module Request
    class ActionProcessor
      def initialize(request, response)
        @request = request
        @response = response
      end

      def call
        SetResponse.new(@response, call_chain).call
      end

      private

      def call_chain
        Chain.new(context).call
      rescue StandardError => e
        desc, status = HandleError.new(e).call
        Result.new(desc, status: status)
      end

      def context
        Parse.new(@request).call
      end
    end
  end
end

# frozen_string_literal: true

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
        context = Context.new(@request)
        Validate.new(context).call
        Chain.new(context).call
      rescue StandardError => e
        desc, status = ErrorHandler.handle(e)
        Result.new(desc, status: status)
      end
    end
  end
end

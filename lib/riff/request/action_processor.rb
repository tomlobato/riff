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
        desc, status = handle_error(e)
        Result.new(desc, status: status)
      end

      def handle_error(error)
        unless error.is_a?(Riff::Exceptions::RiffError)
          Util.log_error(error) 
          Sentry.capture_exception(error) if ENV['RACK_ENV'] == 'production' && defined?(Sentry)
        end
        HandleError.new(error).call
      end
    end
  end
end

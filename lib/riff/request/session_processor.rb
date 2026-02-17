# frozen_string_literal: true

module Riff
  module Request
    class SessionProcessor
      DEBUG = false
      ACTIONS = { login: "login", logout: "logout", refresh: "refresh", check: "check" }

      def initialize(request, response, type)
        @request = request
        @response = response
        @type = type
      end

      def call
        puts "2 Session action: '#{@type}' #{@type.class}" if DEBUG
        SetResponse.new(@response, sign_in_out).call
      end

      private

      def sign_in_out
        call_session
      rescue StandardError => e
        Util.log_error(e) unless e.is_a?(Riff::Exceptions::RiffError)
        desc, status = HandleError.new(e).call
        Result.new(desc, status: status)
      end

      def call_session
        case @type
        when ACTIONS[:login]
          puts "3 Session action: '#{@type}' #{@type.class}" if DEBUG
          Session::Open.new(@request).call
        when ACTIONS[:logout]
          puts "3 Session action: '#{@type}' #{@type.class}" if DEBUG
          Session::Close.new(@request.headers).call
        when ACTIONS[:refresh]
          puts "3 Session action: '#{@type}' #{@type.class}" if DEBUG
          Session::Refresh.new(@request.headers).call
        when ACTIONS[:check]
          puts "3 Session check" if DEBUG
          Request::Result.new({})
        else
          puts "3 Session else" if DEBUG
          raise(invalid_request_path)
        end
      end

      def invalid_request_path
        msg = "'#{@type}' is not a valid session action. Expected actions: #{ACTIONS.values.join(", ")}."
        Exceptions::InvalidRequestPath.new(msg)
      end
    end
  end
end

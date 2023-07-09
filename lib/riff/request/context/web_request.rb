# frozen_string_literal: true

module Riff
  module Request
    class Context
      module WebRequest
        def headers
          request.headers
        end

        def params=(par)
          @params = par
        end

        def params
          @params || raw_params
        end

        def raw_params
          @raw_params ||= request.params.deep_symbolize_keys
        end

        def path
          request.path
        end

        def remote_ip
          @remote_ip ||= RemoteIp.new(headers).call
        end

        # TODO validate
        def request_method
          @request_method ||= Util.const_get(:Riff, :HttpVerbs, request.request_method.upcase.to_sym)
        end

        def url
          request.url
        end
      end
    end
  end
end

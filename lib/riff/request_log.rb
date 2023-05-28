# frozen_string_literal: true

module Riff
  class RequestLog
    include Singleton

    HEADER_FIELDS = %w[CONTENT_TYPE HTTP_COOKIE HTTP_X_APP_DEVICE HTTP_AUTHORIZATION].freeze

    attr_accessor :on, :requests

    def self.collect(req, resp)
      instance.collect(req, resp)
    end

    def self.write_log
      instance.write_log
    end

    def initialize
      @requests = {}
      setup
    end

    def write_log
      File.write(@test_request_log_path, requests.to_yaml)
    end

    def collect(req, resp)
      path = normalized_path(req)
      verb = read_verb(req)
      verb_key = verb.downcase.to_sym
      requests[path] ||= {}
      requests[path][verb_key] ||= []
      requests[path][verb_key] << { request: request(req, path, verb), response: response(resp) }
    end

    private

    def setup
      @test_request_log_path = Conf.get(:test_request_log_path)
      raise(StandardError, path_not_set_error_msg) unless @test_request_log_path
    end

    def path_not_set_error_msg
      "Riff request log path not set. Use Conf.set(:test_request_log_path, '...')."
    end

    def normalized_path(req)
      req.env["PATH_INFO"].sub(%r{/(\d+)(:.*)?$}, '/{id}\\2').sub("/:", "/").to_sym
    end

    def read_verb(req)
      req.env["REQUEST_METHOD"]
    end

    def response(resp)
      {
        status: resp.status,
        content_type: resp.headers["Content-Type"],
        body: resp.body
      }
    end

    def request(req, path, verb)
      {
        verb: verb,
        path: path.to_s,
        query: req.env["rack.request.query_hash"],
        body: req.env["rack.input"].gets.presence,
        headers: headers(req)
      }
    end

    def headers(req)
      req.env.slice(*HEADER_FIELDS).transform_keys do |k|
        k.sub(/^HTTP_/, "").downcase.to_sym
      end
    end
  end
end

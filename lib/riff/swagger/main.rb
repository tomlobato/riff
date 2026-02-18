# frozen_string_literal: true

module Riff
  module Swagger
    class Main
      def initialize(base_path)
        @base_path = base_path
        @context = context
        @examples = load_examples
      end

      def generate
        {
          **Conf.oas_root.to_h,
          paths: paths
        }
      end

      private

      def load_examples
        test_request_log_path = Conf.test_request_log_path
        raise(StandardError, path_not_set_error_msg) unless test_request_log_path.present?
        raise(StandardError, path_not_found_error_msg(test_request_log_path)) unless File.exist?(test_request_log_path)

        YAML.safe_load(File.read(Conf.test_request_log_path), permitted_classes: [Symbol])
      end

      def path_not_set_error_msg
        "Riff request log path not set. Use Conf.set(:test_request_log_path, '...')."
      end

      def path_not_found_error_msg(test_request_log_path)
        "File #{test_request_log_path} not found"
      end

      def paths
        Read.new.call.map do |path, verb|
          [path, verbs(path, verb)]
        end.to_h
      end

      def verbs(path, verb_hash)
        verb_hash.map do |verb, data|
          {
            verb.downcase => build_verb(path, verb, data)
          }
        end.inject({}, :merge)
      end

      def build_verb(path, verb, data)
        Verb.new(data[:tag], data[:action_class], data[:validator_class], @context, path, verb, @examples).call
      end

      SwaggerContext = Struct.new(:id, :user, :custom, keyword_init: true)
      SwaggerCustom = Struct.new(:app_device, keyword_init: true)

      def context
        user_class = Conf.default_auth_user_class
        user = user_class.last
        raise("No #{user_class} record found — seed the database before generating swagger docs") unless user

        SwaggerContext.new(
          id: 123,
          user: user,
          custom: SwaggerCustom.new(app_device: "android")
        )
      end
    end
  end
end

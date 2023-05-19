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
          **Conf.get(:oas_root).to_h,
          paths: paths
        }
      end

      private

      def load_examples
        request_log_path = Conf.get(:request_log_path)
        raise(StandardError, path_not_set_error_msg) unless request_log_path.present?
        raise(StandardError, path_not_found_error_msg(request_log_path)) unless File.exist?(request_log_path)

        YAML.load(File.read(Conf.get(:request_log_path)))
      end
  
      def path_not_set_error_msg
        "Riff request log path not set. Use Conf.set(:request_log_path, '...')."
      end

      def path_not_found_error_msg(request_log_path)
        "File #{request_log_path} not found"
      end

      def paths
        Read.new.call.map do |path, verb|
          [path, verbs(path, verb)]
        end.to_h
      end

      def verbs(path, verb)
        verb.map do |verb, data|
          {
            verb.downcase => build_verb(path, verb, data)
          }
        end.inject(&:merge)
      end

      def build_verb(path, verb, data)
        Verb.new(data[:tag], data[:action_class], data[:validator_class], @context, path, verb, @examples).call
      end

      def context
        ctx = Riff::Request::Context.new(id: 123)
        user_class = Conf.get(:default_auth_user_class)
        user = user_class.last
        unless user
          company = Company.new(nome_fantasia: 'Company')
          user = user_class.new(
            name: 'User', 
            email: 'asd@asd.com', 
            username: 'user', 
            password: '123456', 
            confirmation_password: '123456', 
            company_id: company.id
          )
        end
        ctx.set(:user, user)
        ctx.set(:app_device, 'android')
        ctx
      end
    end
  end
end

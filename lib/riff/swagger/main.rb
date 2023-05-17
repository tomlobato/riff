# frozen_string_literal: true

module Riff
  module Swagger
    class Main
      def initialize(base_path)
        @base_path = base_path
        @context = context
      end

      def generate
        {
          openapi: '3.0.3',
          info: {
            title: 'App Api - Leadfy',
            version: '2.0.0'
          },
          servers: [{
            url: 'https://api-stage.leadfy.com.br/v1',
            description: 'Stage server'
          }, {
            url: 'https://api.leadfy.com.br/v1',
            description: 'Production server'
          }],
          paths: paths
        }
      end

      private

      def paths
        Read.new(@base_path).call.map do |path, verb|
          [path, verbs(verb)]
        end.to_h
      end

      def verbs(verb)
        verb.map do |verb, data|
          {
            verb.downcase => build_verb(data)
          }
        end.inject(&:merge)
      end

      def build_verb(data)
        Verb.new(data[:tag], data[:action_class], data[:validator_class], @context).call
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

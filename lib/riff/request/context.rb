# frozen_string_literal: true

# TODO implement lazy properties

module Riff
  module Request
    class Context
      attr_accessor :resource,
                    :id,
                    :action,
                    :params,
                    :model_name,
                    :model_class,
                    :model_less,
                    :action_class_name,
                    :is_custom_method,
                    :headers,
                    :request_method,
                    :path,
                    :url,
                    :auth_method,
                    :remote_ip

      def initialize(vars)
        vars.each { |k, v| instance_variable_set("@#{k}", v) }
        @store = {}
      end

      def set(key, val)
        @store[key] = val
      end

      def get(key)
        @store[key]
      end
    end
  end
end

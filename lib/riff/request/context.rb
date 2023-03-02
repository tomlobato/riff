# frozen_string_literal: true

module Riff
  module Request
    class Context
      attr_reader :resource,
                  :id,
                  :action,
                  :params,
                  :model_name,
                  :action_class_name,
                  :is_custom_method,
                  :headers,
                  :request_method,
                  :path,
                  :url

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

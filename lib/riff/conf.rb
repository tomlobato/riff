# frozen_string_literal: true

module Riff
  class Conf
    KEYS = %i[
      model_less_resources resource_remap user_fields validate_credentials_methods default_display_error_msg 
      custom_context_class default_auth_user_class no_colon_mode oas_root on_auth test_request_log_path 
      resources_base_module user_login_payload_class user_token_fields default_response_icons
    ]

    include Singleton

    def self.set(key, val)
      instance.set(key, val)
    end

    def self.configure(conf_map)
      conf_map.each { |k, v| set(k, v) }
    end

    def self.get(key)
      instance.get(key)
    end

    def initialize
      @store = {}
    end

    def set(key, val)
      raise "Invalid key: #{key}" unless KEYS.include?(key)
      
      @store[key] = val
    end

    def get(key)
      @store[key]
    end
  end
end

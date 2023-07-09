# frozen_string_literal: true

module Riff
  class Conf
    include Singleton

    SELECT_ALL = Sequel.lit('*').freeze

    KEYS = {
      custom_context_class: nil,
      db: nil,
      default_auth_clause: nil,
      default_auth_fields: SELECT_ALL,
      custom_auth_method: nil,
      default_auth_user_class: nil,
      default_content_type: "application/json",
      default_display_error_msg: "Error processing request",
      default_error_icon: nil,
      default_paginate: true,
      default_per_page: 20,
      default_response_icons: nil,
      field_username: :username,
      logger: lambda { Logger.new(STDOUT) },
      model_less_resources: [],
      no_colon_mode: :id_if_digits_or_uuid,
      oas_root: nil,
      on_user: nil,
      param_username: :username,
      param_password: :password,
      resource_remap: {},
      resources_base_module: lambda { Resources },
      test_request_log_path: nil,
      user_fields: SELECT_ALL,
      user_login_payload_class: nil,
      user_token_fields: SELECT_ALL,
      validate_credentials_methods: lambda { Riff::Auth::DefaultMethod::Token::ValidateCredentials },
    }.freeze

    KEYS.each do |key, val|
      class_eval <<-ACCESSORS, __FILE__, __LINE__ + 1
        def #{key}
          @#{key} || default_value(:#{key})
        end

        def #{key}=(val)
          @#{key} = brush(:#{key}, val)
        end

        def self.#{key}
          instance.#{key}
        end

        def self.#{key}=(val)
          instance.#{key} = val
        end
      ACCESSORS
    end

    private

    def default_value(key)
      return unless (valuer = KEYS[key])

      valuer.is_a?(Proc) ? valuer.call : valuer
    end

    def brush(key, val)
      case key
      when :default_response_icons
        val&.transform_keys(&:to_sym)
      else
        val
      end
    end
  end
end

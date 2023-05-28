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
      default_auth_user_class: nil,
      default_display_error_msg: "Error processing request",
      default_error_icon: nil,
      default_response_icons: nil,
      logger: lambda { Logger.new(STDOUT) },
      model_less_resources: [],
      no_colon_mode: :id_if_digits_or_uuid,
      oas_root: nil,
      on_auth: nil,
      resource_remap: {},
      resources_base_module: lambda { Resources },
      test_request_log_path: nil,
      user_fields: SELECT_ALL,
      user_login_payload_class: nil,
      user_token_fields: SELECT_ALL,
      validate_credentials_methods: lambda { Riff::Auth::DefaultMethod::Token::ValidateCredentials },
    }.freeze

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
      raise("Invalid Riff::Conf key: '#{key}'") unless KEYS.keys.include?(key)

      @store[key] = brush(key, val)
    end

    def get(key)
      @store[key] || default_value(key)
    end

    private

    def default_value(key)
      return unless (valuer = KEYS[key])

      valuer.respond_to?(:call) ? valuer.call : valuer
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

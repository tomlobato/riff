# frozen_string_literal: true

module Riff
  # TODO convert all uses of this class to a dry-validation-contract
  class HashValidator
    def initialize(param, valid_key_map)
      @param = param
      @valid_key_map = valid_key_map
    end

    def call!
      error!("param must be a hash") unless @param.instance_of?(Hash)

      keys = find_invalid_keys
      error!("param has invalid key(s): #{invalid_keys_error_detail(keys)}") unless keys.empty?

      keys = find_invalid_value_keys
      error!("param has invalid value type(s): #{invalid_value_keys_error_detail(keys)}") unless keys.empty?
    end

    private

    def find_invalid_value_keys
      @param.filter_map do |key, val|
        # TODO: handle blank? of booleans
        # TODO give option to deny blank values
        key unless val.blank? || val.class.in?(valid_value_classes(key))
      end
    end

    def find_invalid_keys
      @param.keys - @valid_key_map.keys
    end

    def valid_value_classes(key)
      [@valid_key_map[key]].flatten
    end

    def error!(msg)
      raise(ArgumentError, msg)
    end

    def invalid_keys_error_detail(keys)
      keys.map { |k| "#{k}:#{k.class}" }
          .join(", ")
    end

    def invalid_value_keys_error_detail(invalid_value_keys)
      invalid_value_keys.map do |key|
        "value for key #{key} is a #{@param[key].class} but should be: #{::Util::Array.smart_join(valid_value_classes(key))}"
      end.join("; ")
    end
  end
end

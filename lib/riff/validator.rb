# frozen_string_literal: true

module Riff
  class Validator
    def initialize(class_nodes, params, allow_empty_params: true)
      @class_nodes = class_nodes
      @params = params
      @allow_empty_params = allow_empty_params
      @validator_class = validator_class
    end

    def call
      # puts '--------------------'
      # puts @class_nodes
      # puts 111
      # puts @params
      # puts @allow_empty_params
      # puts @validator_class
      return unless @validator_class

      check_blank! unless @allow_empty_params

      result = @validator_class.new.call(@params)
      thrown_error(result.errors) if result.failure?

      result.to_h
    end

    private

    def validator_class
      Util.const_get(@class_nodes, anchor: true)
    end

    def thrown_error(errors)
      msg = errors.to_h.to_json
      raise(Exceptions::InvalidParameters.new(msg))
    end

    def check_blank!
      # puts 888
      # puts @params.blank?
      thrown_error({nil => "parameters cannot be blank"}) if @params.blank?      
    end
  end
end

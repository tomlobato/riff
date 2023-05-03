# frozen_string_literal: true

module Riff
  class Validate
    def initialize(class_nodes, params, allow_empty_params: true, context: nil)
      @class_nodes = class_nodes
      @params = params
      @allow_empty_params = allow_empty_params
      @context = context
      @validator_class = validator_class
    end

    def call
      return unless @validator_class

      check_blank! unless @allow_empty_params

      result = @validator_class.new.call(@params)
      thrown_error(result.errors) if result.failure?

      result.to_h
    end

    private

    def validator_class
      klass = Util.const_get(@class_nodes, anchor: true)
      raise(Exceptions::NotImplemented, "#{@class_nodes.join('::')} must me implemented!") unless klass
      return klass if klass.superclass == Riff::Validator
      return klass.new.klass(@context) if klass.superclass == Riff::DynamicValidator
      
      raise(Exceptions::NotImplemented, "Validator must be a subclass of Riff::Validator or Riff::DynamicValidator, but it is #{klass}")
    end

    def thrown_error(errors)
      msg = errors.to_h.to_json
      raise(Exceptions::InvalidParameters.new(msg))
    end

    def check_blank!
      thrown_error({nil => "parameters cannot be blank"}) if @params.blank?      
    end
  end
end

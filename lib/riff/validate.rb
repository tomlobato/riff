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
      raise_validation_error!(result.errors) if result.failure?

      result.to_h
    end

    private

    def validator_class
      klass = Util.const_get(@class_nodes, anchor: true)
      klass ||= Riff::FallbackValidator

      case klass.superclass.to_s
      when "Riff::Validator"
        klass
      when "Riff::DynamicValidator"
        klass.new.klass(@context)
      else
        raise(
          Exceptions::NotImplemented,
          "Validator superclass must be Riff::Validator or Riff::DynamicValidator, but it is #{klass.superclass}"
        )
      end
    end

    def raise_validation_error!(errors)
      Exceptions::InvalidParameters.raise!(field_errors: errors.to_h)
    end

    def check_blank!
      raise_validation_error!({ nil => "parameters cannot be blank" }) if @params.blank?
    end
  end
end

module Riff
  class Validator
    def initialize(class_nodes, params)
      @class_nodes = class_nodes
      @params = params
      @validator_class = validator_class
    end

    def call
      return unless @validator_class

      result = @validator_class.new.call(@params)
      thrown_error(result.errors) if result.failure?          
    end

    private

    def validator_class
      Util.const_get(@class_nodes, anchor: true)
    end

    def thrown_error(errors)
      msg = errors.to_h.to_json
      raise(Exceptions::InvalidParameters, msg)
    end
  end
end

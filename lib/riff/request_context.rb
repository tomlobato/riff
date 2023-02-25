module Riff
  class RequestContext
    attr_reader :resource, :id, :action, :params, :model_name

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

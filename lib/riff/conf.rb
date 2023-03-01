module Riff
  class Conf
    include Singleton

    def initialize
      @store = {}
    end

    def set(key, val)
      @store[key] = val
    end

    def get(key)
      @store[key]
    end

    def self.set(key, val)
      instance.set(key, val)
    end

    def self.get(key)
      instance.get(key)
    end
  end
end

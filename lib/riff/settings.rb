module Riff
  class Settings
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
  end
end

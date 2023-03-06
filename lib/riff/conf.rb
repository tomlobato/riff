# frozen_string_literal: true

module Riff
  class Conf
    include Singleton

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
      @store[key] = val
    end

    def get(key)
      @store[key]
    end
  end
end

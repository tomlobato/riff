module Riff
  class Util
    def self.const_get(name)
      Object.const_get(name)
    rescue NameError
      nil
    end
  end
end

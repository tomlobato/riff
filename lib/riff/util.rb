module Riff
  class Util
    def self.const_get(name)
      Object.const_get(name.constantize)
    rescue => NameError
      nil
    end
  end
end

# frozen_string_literal: true

module Riff
  class DynamicValidator
    def klass(_context)
      raise(NotImplementedError, "You must implement #{self.class}#klass(context)")
    end
  end
end

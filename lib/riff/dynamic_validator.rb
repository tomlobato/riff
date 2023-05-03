# frozen_string_literal: true

module Riff
  class DynamicValidator
    def klass
      raise(NotImplementedError, "You must implement #{self.class}#klass")
    end
  end
end

# frozen_string_literal: true

module Riff
  class BaseAction
    def initialize(context)
      @context = context
      @user = context.user
    end

    def call
      raise(Exceptions::NotImplemented)
    end
  end
end

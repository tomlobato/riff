# frozen_string_literal: true

module Riff
  # Base class for custom (non-CRUD) actions.
  # For standard CRUD actions (Index, Create, Show, Update, Delete), use Actions::Base.
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

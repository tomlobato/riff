# frozen_string_literal: true

module Riff
  class Authorize
    def initialize(context, user)
      @context = context
      @user = user
    end

    def default
      false
    end

    def create?
      default
    end

    def show?
      default
    end

    def index?
      default
    end

    def update?
      default
    end

    def delete?
      default
    end
  end
end

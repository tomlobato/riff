# frozen_string_literal: true

module Riff
  class Enable
    # Enable CRUD actions

    def default_enable_action
      true
    end

    def create?
      default_enable_action
    end

    def show?
      default_enable_action
    end

    def index?
      default_enable_action
    end

    def update?
      default_enable_action
    end

    def delete?
      default_enable_action
    end
  end
end

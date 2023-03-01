# frozen_string_literal: true

module Riff
  class BaseActionSettings
    def default
      true
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

# frozen_string_literal: true

module Riff
  class BaseResourceSettings
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

    # Pagination

    def paginate?
      paginate = Conf.get(:default_paginate)
      paginate.nil? || paginate
    end

    def per_page
      Conf.get(:default_per_page) || Constants::DEFAULT_PER_PAGE
    end

    # Select fields

    def default_fields
      nil
    end

    def index_fields
      default_fields
    end

    def show_fields
      default_fields
    end
  end
end

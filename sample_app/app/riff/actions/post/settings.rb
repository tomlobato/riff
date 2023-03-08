# frozen_string_literal: true

module Actions
  module Post
    class Settings < Riff::BaseResourceSettings
      ####
      # Enable/disable CRUD actions for /actions/posts requests.
      # Available methods: create?, show?, index?, update? and delete?
      # Custom methods are always enabled
      # Use the method default_enable_action to set them all at once

      # def create?
      #   true
      # end

      # def index?
      #   false
      # end

      ####
      # Configure pagination

      # def paginate?
      #   true
      # end

      # def per_page
      #   50
      # end

      ####
      # Configure fields

      def index_fields
        %i[id body user_id company_id]
      end

      # def show_fields
      #   %i[id body user_id]
      # end
    end
  end
end

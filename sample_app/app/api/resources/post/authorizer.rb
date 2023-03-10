# frozen_string_literal: true

module Resources
  module Post
    class Authorizer < Riff::BaseAuthorizer
      def default
        { user_id: @user.id }
      end

      def create?
        default.merge(company_id: @user.company_id)
      end

      def update?
        create?
      end

      def stats?
        default.merge(is_admin: true)
      end
    end
  end
end

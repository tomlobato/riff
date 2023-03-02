# frozen_string_literal: true

module Actions
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
    end
  end
end

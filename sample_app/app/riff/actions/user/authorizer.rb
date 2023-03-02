# frozen_string_literal: true

module Actions
  module User
    class Authorizer < Riff::BaseAuthorizer
      def default
        { company_id: @user.company_id } if @user.is_admin
      end
    end
  end
end

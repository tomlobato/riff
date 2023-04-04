# frozen_string_literal: true

module Resources
  module User
    class Authorize < Riff::Authorize
      def default
        { company_id: @user.company_id } if @user.is_admin
      end

      def update?
        false
      end

      def show?
        'string'
      end

      def custom_method?
        true
      end

      def custom_method2?
        true
      end
    end
  end
end

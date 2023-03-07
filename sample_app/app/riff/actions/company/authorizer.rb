# frozen_string_literal: true

module Actions
  module Company
    class Authorizer < Riff::BaseAuthorizer
      def create?
        true
      end
    end
  end
end

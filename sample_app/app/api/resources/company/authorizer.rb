# frozen_string_literal: true

module Resources
  module Company
    class Authorize < Riff::Authorize
      def create?
        true
      end
    end
  end
end

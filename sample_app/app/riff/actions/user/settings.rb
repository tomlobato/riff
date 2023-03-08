# frozen_string_literal: true

module Actions
  module User
    class Settings < Riff::BaseResourceSettings
      def paginate?
        false
      end
    end
  end
end

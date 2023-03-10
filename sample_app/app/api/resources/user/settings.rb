# frozen_string_literal: true

module Resources
  module User
    class Settings < Riff::BaseResourceSettings
      def paginate?
        false
      end
    end
  end
end

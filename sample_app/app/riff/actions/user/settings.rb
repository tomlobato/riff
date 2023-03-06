# frozen_string_literal: true

module Actions
  module User
    class Settings < Riff::BaseActionSettings
      def paginate?
        false
      end
    end
  end
end

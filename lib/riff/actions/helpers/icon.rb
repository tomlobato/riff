# frozen_string_literal: true

module Riff
  module Actions
    module Helpers
      class Icon
        def initialize(icon, success)
          @icon = icon
          @success = success
        end

        def call
          return unless @icon

          @icon == true ? default_icon : @icon
        end

        private

        def default_icon
          return unless (default_response_icons = Conf.get(:default_response_icons))

          default_response_icons[@success ? :success : :error]
        end
      end
    end
  end
end

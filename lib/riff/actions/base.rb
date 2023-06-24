# frozen_string_literal: true

module Riff
  module Actions
    class Base
      include Helpers::ResultBuilder

      extend Forwardable
      def_delegators :@context, :params

      def initialize(context)
        @context = context
        @user = @context.get(:user)
      end

      # :nocov:
      def call
        raise(Exceptions::NotImplemented)
      end
      # :nocov:

      def error_msg
        # may implement
      end

      def error_icon
        # may implement
      end

      private

      def model_class
        @context.model_class
      end

      def scope
        @scope ||= @context.get(:scope)
      end

      def settings
        @settings ||= @context.settings
      end
    end
  end
end

# frozen_string_literal: true

module Riff
  module Actions
    class Base
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

      private

      def model_class
        @context.model_name.constantize
      end

      def scope
        @scope ||= @context.get(:scope)
      end

      def settings
        @settings ||= @context.get(:settings)
      end
    end
  end
end

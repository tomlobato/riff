# frozen_string_literal: true

module Riff
  module DefaultActions
    class Base
      extend Forwardable
      def_delegators :@context, :params

      def initialize(context)
        @context = context
      end

      def call
        raise(Exceptions::NotImplemented)
      end

      private

      def model_class
        @context.model_name.constantize
      end

      def scope
        @scope ||= @context.get(:scope)
      end
    end
  end
end

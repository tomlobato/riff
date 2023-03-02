# frozen_string_literal: true

module Riff
  module DefaultActions
    class Index < Base
      def call
        Request::Result.new(body)
      end

      private

      def body
        query.map(&:values)
      end

      def query
        model_class.where(scope.to_h)
      end
    end
  end
end

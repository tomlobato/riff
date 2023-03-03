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
        model_class.where(filters)
      end

      def filters
        request_filters.merge(enforced_filters)
      end
      
      def enforced_filters
        scope.to_h
      end

      def request_filters
        @context.params.to_h
      end
    end
  end
end

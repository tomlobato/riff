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
        offset, limit = pagination
        model_class.where(filters).offset(offset).limit(limit).order(*order)
      end

      def filters
        request_filters.merge(enforced_filters)
      end
      
      def enforced_filters
        scope.to_h
      end

      def request_filters
        f = @context.params.deep_dup
        f.delete(:_order)
        f.delete(:_limit)
        f.delete(:_page)
        f.to_h
      end

      def pagination
        Helpers::Pagination.new(@context.params, @context.get(:settings)).offset_limit
      end
      
      def order
        Helpers::Order.new(@context.params, @context.model_class).order
      end
    end
  end
end

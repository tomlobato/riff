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
        model_class.select(*select).where(filters).offset(offset).limit(limit).order(*order)
      end

      def filters
        request_filters.merge(enforced_filters)
      end

      def enforced_filters
        scope.to_h
      end

      def request_filters
        f = @context.params.deep_dup
        %i[_order _limit _page].each { |k| f.delete(k) }
        f
      end

      def pagination
        Helpers::Pagination.new(@context.params, settings).offset_limit
      end

      def order
        Helpers::Order.new(@context.params, @context.model_class).order
      end

      def select
        settings.index_fields || model_class.columns
      end
    end
  end
end

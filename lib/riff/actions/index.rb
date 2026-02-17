# frozen_string_literal: true

module Riff
  module Actions
    class Index < Base
      def call
        Request::Result.new({ data: body })
      end

      private

      def body
        query.map { |rec| rec.values.merge(extra_fields(rec).to_h) }
      end

      def query
        q = model_class.select(*select)

        q = q.join(*join) if join

        f_hash, f_sequel = [filters].compact.flatten(1)
        q = q.where(f_hash) if f_hash.present?
        f_sequel.each { |f| q = q.where(f) } if f_sequel.present?

        offset, limit = pagination
        q = q.offset(offset).limit(limit) if offset && limit

        q = q.order(*[order].flatten(1))

        q
      end

      def join
        # may implement
      end

      def filters
        all =[
          request_filters,
          enforced_filters,
          extra_filters,
        ]
        hash_filters = all.compact.select { |f| f.is_a?(Hash) }.reduce(:merge)
        sequel_literal_filters = all.compact.select { |f| f.is_a?(Sequel::SQL::PlaceholderLiteralString) }
        [hash_filters, sequel_literal_filters]
      end

      def enforced_filters
        scope
      end

      def request_filters
        @context.params.reject { |k, _| k.to_s.index("_") == 0 }
      end

      def extra_filters
        # may implement
      end

      def extra_fields(_rec)
        # may implement
      end

      def pagination
        Helpers::Pagination.new(@context.params, paginate_settings).offset_limit
      end

      def paginate_settings
        { paginate: paginate?, per_page: per_page }
      end

      def paginate?
        paginate = Conf.default_paginate
        paginate.nil? || paginate
      end

      def per_page
        Conf.default_per_page || Constants::DEFAULT_PER_PAGE
      end

      def default_order
        # May implement
      end

      def order
        Helpers::Order.new(
          @context.params[:_order].presence || default_order,
          @context.model_class,
          allow_extra_fields: (order_allow_extra_fields.to_a << default_order).compact
        ).order
      end

      def order_allow_extra_fields
        # may implement
      end

      def select
        settings.index_fields || model_class.columns
      end
    end
  end
end

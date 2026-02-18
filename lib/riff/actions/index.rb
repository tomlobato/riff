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
        offset, limit = pagination
        q = q.offset(offset).limit(limit).order(*order)
        apply_filters(q)
      end

      def join
        # may override — e.g. [:other_table, { foreign_key: :id }]
      end

      def default_filters
        [
          request_filters,
          enforced_filters,
          extra_filters
        ].reject(&:blank?)
      end

      def apply_filters(q_result)
        hash_filters = {}
        clauses = []
        default_filters.flatten.compact.each do |filter|
          case filter
          when Hash
            hash_filters.merge!(filter)
          when Sequel::LiteralString, Sequel::SQL::PlaceholderLiteralString
            clauses << filter
          when String
            clauses << Sequel.lit(filter)
          else
            raise "Invalid filter type: #{filter.class}. It must be a hash, a Sequel literal or a valid Sequel literal string."
          end
        end
        clauses.unshift(hash_filters) unless hash_filters.empty?
        clauses.each { |f| q_result = q_result.where(f) }
        q_result
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
        Conf.default_per_page
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

# frozen_string_literal: true

module Riff
  module Actions
    class Index < Base
      include Helpers::Common
      
      def call
        Request::Result.new({ data: body })
      end

      private

      def body
        query.map { |rec| rec.values.merge(extra_fields(rec).to_h) }
      end

      def query
        offset, limit = pagination
        q_result = model_class.select(*select).offset(offset).limit(limit).order(*order)
        apply_filters(q_result)
      end

      def filters
        request_filters.merge(enforced_filters).merge(extra_filters.to_h)
      end

      def apply_filters(q_result)
        f = filters
        return q_result if f.blank?

        case f
        when Array
          f.each { |f_item| q_result = q_result.where(f_item) }
        when Hash
          q_result = q_result.where(f)
        else
          raise "Invalid filters type: #{f.class}. It must be a hash or an array of valid Sequel clauses."
        end
        q_result
      end

      def enforced_filters
        scope.to_h
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

      def order
        Helpers::Order.new(
          @context.params[:_order],
          @context.model_class,
          allow_extra_fields: order_allow_extra_fields
        ).order
      end

      def order_allow_extra_fields
        # may implement
      end

      def select
        parse_fields(settings.index_fields) || model_class.columns
      end
    end
  end
end

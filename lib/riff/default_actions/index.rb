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
        Helpers::Pagination.new(@context.params, paginate_settings).offset_limit
      end

      def paginate_settings
        { paginate: paginate?, per_page: per_page }
      end

      def paginate?
        paginate = Conf.get(:default_paginate)
        paginate.nil? || paginate
      end
  
      def per_page
        Conf.get(:default_per_page) || Constants::DEFAULT_PER_PAGE
      end

      def order
        Helpers::Order.new(@context.params[:_order], @context.model_class, allow_extra_fields: order_allow_extra_fields).order
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

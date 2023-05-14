# frozen_string_literal: true

module Riff
  module Actions
    module Helpers
      module Record
        private

        def record(fields = nil)
          fields ||= model_class.columns
          record = query(fields)
          record_not_found! unless record

          record
        end

        def query(fields)
          q = model_class
            .where(id: @context.id, **scope.to_h)
            .where(extra_filters.to_h)
            .select(*fields)
          tap_query(q)
          q.first
        end

        def tap_query(_query)
          # may implement
        end

        def extra_filters
          # may implement
        end

        def record_not_found!
          raise(Riff::Exceptions::ResourceNotFound.create(@context.resource, @context.id))
        end
      end
    end
  end
end

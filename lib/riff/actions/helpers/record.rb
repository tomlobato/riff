# frozen_string_literal: true

module Riff
  module Actions
    module Helpers
      module Record
        private

        def record
          fields ||= model_class.columns
          rec = query.first
          record_not_found! unless rec

          rec
        end

        def query
          model_class.where(pk_field => @context.id, **scope.to_h).where(extra_filters.to_h).select(*select)
        end

        def pk_field
          Sequel[model_class.table_name][model_class.primary_key]
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

# frozen_string_literal: true

module Riff
  module DefaultActions
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
          model_class
            .where(id: @context.id, **scope.to_h)
            .select(*fields)
            .first
        end

        def record_not_found!
          raise(Riff::Exceptions::ResourceNotFound.create(@context.resource, @context.id))
        end
      end
    end
  end
end

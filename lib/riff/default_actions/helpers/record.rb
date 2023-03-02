# frozen_string_literal: true

module Riff
  module DefaultActions
    module Helpers
      module Record
        private

        def record
          record = model_class.find(id: @context.id.to_i, **scope.to_h)
          raise(record_not_found) unless record

          record
        end

        def record_not_found
          Riff::Exceptions::ResourceNotFound.new("unable to find #{@context.resource} with id '#{@context.id}'")
        end
      end
    end
  end
end

# frozen_string_literal: true

module Riff
  module Actions
    module Helpers
      module Common
        private

        def parse_fields(fields)
          case fields
          when Hash
            Util.fields_from_map(fields)
          when Array
            fields
          else
            raise ArgumentError, "Invalid fields type: #{fields.class}. It must be a hash or an array."
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Riff
  module Actions
    module Helpers
      class Pagination
        def initialize(params, settings)
          @params = params
          @settings = settings
          @page = page
          @limit = limit
        end

        def offset_limit
          [offset, @limit]
        end

        private

        def offset
          return unless @page && @limit

          (@page - 1) * @limit
        end

        def page
          value = read(:_page)
          return unless value

          raise_invalid_pagination!(:_page) if value < 1

          value
        end

        def limit
          value = read(:_limit) || @settings[:per_page]
          [value, Conf.max_per_page].compact.min
        end

        def read(key)
          value = @params[key].presence
          return unless value

          raise_invalid_pagination!(key) unless @settings[:paginate]
          raise_invalid_pagination!(key) unless value =~ Constants::ONLY_DIGITS

          Integer(value, 10)
        end

        def raise_invalid_pagination!(key)
          Exceptions::InvalidParameters.raise!(field_errors: { key => @params[key] })
        end
      end
    end
  end
end

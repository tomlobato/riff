# frozen_string_literal: true

module Riff
  module Actions
    module Helpers
      class Pagination
        # Page size is `_limit` only. `_per_page` is refused out loud — a client
        # sending it must not get the default page size without noticing.
        REFUSED_PARAMS = %i[_per_page].freeze

        def initialize(params, settings)
          @params = params
          @settings = settings
          refuse_params!
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

        # An action that does not paginate returns every row: the default page
        # size applies only where pagination is on.
        def limit
          value = read(:_limit)
          return unless value || @settings[:paginate]

          [value || @settings[:per_page], Conf.max_per_page].compact.min
        end

        def read(key)
          value = @params[key].presence
          return unless value

          raise_invalid_pagination!(key) unless @settings[:paginate]
          raise_invalid_pagination!(key) unless value =~ Constants::ONLY_DIGITS

          Integer(value, 10)
        end

        def refuse_params!
          REFUSED_PARAMS.each { |key| raise_invalid_pagination!(key) if @params.key?(key) }
        end

        def raise_invalid_pagination!(key)
          Exceptions::InvalidParameters.raise!(field_errors: { key => @params[key] })
        end
      end
    end
  end
end

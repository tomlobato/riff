# frozen_string_literal: true

module Riff
  module DefaultActions
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
          read(:_limit) || @settings.per_page
        end

        def read(key)
          value = @params[key].presence
          return unless value

          raise_invalid_pagination!(key) unless @settings.paginate?
          raise_invalid_pagination!(key) unless value =~ Constants::ONLY_DIGITS

          Integer(value, 10)
        end

        def raise_invalid_pagination!(key)
          raise(Exceptions::InvalidParameters, { key => @params[key] }.to_json)
        end
      end
    end
  end
end

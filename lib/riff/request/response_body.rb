module Riff
  module Request
    class ResponseBody
      FIELDS = %i[success data msg meta extra].freeze

      def initialize(body, status)
        @status = status
        @body = brush_body(body)
      end

      def call
        @body.is_a?(String) ? @body : build_result(@body)
      end

      private

      def build_result(raw)
        raw[:success] = success?
        cleanup!(raw)
        raw
      end

      def cleanup!(raw)
        FIELDS.each do |field|
          next if field == :success

          raw.delete(field) unless raw[field].present?
        end
      end

      def success?
        return @success if defined?(@success)

        @success = @status.nil? || @status < 400
      end

      def brush_body(raw)
        case raw
        when String
          if success?
            { data: raw }
          else
            { msg: { text: raw, type: "error" } }
          end
        when Array, Hash
          raw
        when NilClass
          ""
        else
          raise(Riff::Exceptions::InvalidResponseBody, "Unhandled body class '#{raw.class}'")
        end
      end
    end
  end
end

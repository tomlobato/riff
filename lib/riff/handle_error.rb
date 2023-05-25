# frozen_string_literal: true

module Riff
  class HandleError
    DEFAULT_DISPLAY_ERROR_MSG = "Error processing request"
    DEFAULT_HTTP_STATUS = 500

    def initialize(error)
      @error = error
    end

    def call
      [result_body, status]
    end

    private

    def result_body
      return custom_error_body if riff_error? && @error.raw_msg

      riff_error? ? riff_error_body : base_error_body
    end

    def custom_error_body
      { msg: @error.raw_msg }
    end

    def riff_error?
      @error.is_a?(Riff::Exceptions::RiffError)
    end

    def riff_error_body
      body = base_error_body
      body[:msg][:fields] = @error.field_errors if @error.field_errors.present?
      body
    end

    def base_error_body
      display = display_msg
      detail = detail_msg
      detail = nil if detail == display
      {
        msg: { text: display, detail: detail, type: "error" }.compact
      }
    end

    def detail_msg
      return if ENV["RACK_ENV"] == "production"
      return @error.message if @error.message != @error.class.name
      return message_from_class_name if riff_error_400?
    end

    def display_msg
      return @error.display_msg if riff_error? && @error.display_msg
      return message_from_class_name if riff_error_400?

      Conf.get(:default_display_error_msg) || DEFAULT_DISPLAY_ERROR_MSG
    end

    def message_from_class_name
      I18n.t(@error.class.name.split("::").last.underscore)
    end

    def riff_error_400?
      riff_error? && @error.class::WEB_STATUS.between?(400, 499)
    end

    def status
      riff_error? ? @error.class::WEB_STATUS : DEFAULT_HTTP_STATUS
    end
  end
end

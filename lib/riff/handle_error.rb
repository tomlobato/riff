# frozen_string_literal: true

module Riff
  class HandleError
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
        msg: { text: display, detail: detail, type: "error", icon: error_icon }.compact
      }
    end

    def error_icon
      icon = nil
      icon = @error.icon if riff_error?
      icon ||= Conf.default_error_icon
      raise(RuntimeError, "icon should be a Symbol or Hash, but it is a #{icon.class}") unless icon.is_a?(Symbol) || icon.is_a?(Hash)

      icon.is_a?(Symbol) ? default_icon(icon) : icon
    end

    def default_icon(key)
      raise(RuntimeError, "Conf.default_response_icons not set") unless Conf.default_response_icons
      raise(RuntimeError, "Conf.default_response_icons has no key '#{key}'") unless Conf.default_response_icons[key]

      Conf.default_response_icons[key]
    end

    def detail_msg
      return if ENV["RACK_ENV"] == "production"
      return @error.message if @error.message != @error.class.name
      return message_from_class_name if riff_error_400?
    end

    def display_msg
      if riff_error? 
        @error.display_msg || message_from_class_name
      else
        Conf.default_display_error_msg
      end
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

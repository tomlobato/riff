# frozen_string_literal: true

module Riff
  class HandleError
    def initialize(error)
      @error = error
      @is_web_error = Util.web_exception?(error)
    end

    def call
      print_error unless @is_web_error
      [desc, status]
    end

    private

    def print_error
      err_msg = Util.error_desc(@error)
      warn(err_msg) if err_msg
    end

    def desc
      { 
        msg: { 
          text: desc_error,
          type: 'error'
        }.merge(extra_desc.to_h)
      }
    end

    def desc_error
      @is_web_error ? @error.default_err_msg : "Error executing requested operation"
    end

    def extra_desc
      return unless @error.message.present?

      if @is_web_error && @error.class::JSON
        { fields: Oj.load(@error.message) }
      else
        { detail: @error.message } unless @error.message == @error.class.to_s
      end
    end

    def status
      @is_web_error ? @error.class::WEB_STATUS : 500
    end
  end
end

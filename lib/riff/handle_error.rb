module Riff
  class HandleError
    def initialize(error)
      @error = error
      @is_web_error = Util.is_web_exception?(error)
    end

    def call
      print_error unless @is_web_error
      [desc, status]
    end
    
    private
    
    def print_error
      $stderr.puts(Util.error_desc(@error))
    end

    def desc
      {error: @error.class::ERR_MSG}.merge(extra_desc.to_h)
    end

    def extra_desc
      return unless @error.message.present?

      if @error.class::JSON
        {messages: Oj.load(@error.message)}
      else
        {details: @error.message}
      end
    end
    
    def status
      @is_web_error ? @error.class::WEB_STATUS : 500
    end
  end
end

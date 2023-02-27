module Riff
  class HandleError
    def initialize(error)
      @error = error
      @is_web = Util.is_web_exception?(error)
    end

    def call
      print_error unless @is_web
      [desc, status]
    end
    
    private
    
    def print_error
      $stderr.puts(Util.error_desc(@error))
    end

    def desc
      {error: "#{@error.class}: #{@error.message}"}
    end

    def status
      @is_web ? @error.class::WEB_STATUS : 500
    end
  end
end

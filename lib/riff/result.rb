module Riff
  class Result
    attr_reader :body, :content_type, :headers, :status

    def initialize(body, content_type: nil, headers: nil, status: nil)
      @body = body
      @content_type = content_type
      @headers = headers
      @status = status
    end
  end
end

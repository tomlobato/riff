module Riff
  module Exceptions
    class Error422 < StandardError
      WEB_STATUS = 422
    end

    class Error404 < StandardError
      WEB_STATUS = 404
    end

    class Error500 < StandardError
      WEB_STATUS = 500
    end

    # 422
    class InvalidPathNodes < Error422
    end

    class InvalidRequestPath < Error422
    end

    class OutOfBoundsPathNodes < Error422
    end

    class InvalidParams < Error422
    end

    # 404
    class ResourceNotFound < Error404
    end

    class ActionNotFound < Error404
    end

    # 500
    class InvalidResponseBody < Error500
    end
  end
end

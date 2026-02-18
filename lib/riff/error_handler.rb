# frozen_string_literal: true

module Riff
  module ErrorHandler
    module_function

    def handle(error)
      unless error.is_a?(Riff::Exceptions::RiffError)
        Util.log_error(error)
        Conf.error_reporter&.call(error)
      end
      HandleError.new(error).call
    end
  end
end

# frozen_string_literal: true

module Riff
  module Util
    module_function

    def const_get(*nodes, anchor: false, reraise: false)
      name = nodes.flatten.join("::")
      name.prepend("::") if anchor
      Object.const_get(name)
    rescue NameError
      raise if reraise

      nil
    end

    def web_exception?(error)
      error.class.ancestors[0].to_s.index("Riff::Exceptions::")
    end

    def error_desc(error)
      "#{error.class}: #{error.message}"
    end

    def record_errors(rec_errors)
      errors = {}
      rec_errors&.each { |k, v| errors[k] = v.uniq }
      errors
    end

    def log_error(error)
      Conf.logger.error(error_desc(error))
      Conf.logger.error(error.backtrace.to_a.join("\n"))
    end
  end
end

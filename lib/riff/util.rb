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
      "#{error.class}: #{error.message}" #unless ENV["RACK_ENV"] == "test"
    end

    def record_errors(rec_errors)
      errors = {}
      rec_errors.each{|k, v| errors[k] = v.uniq }
      errors
    end

    # def id?(str)
    #   str =~ Constants::ONLY_DIGITS || str =~ Constants::UUID
    # end

    def log_error(error)
      warn(error_desc(error))
      warn(error.backtrace.to_a.join("\n"))
    end
  end
end

module Riff
  class Util
    def self.const_get(*nodes, anchor: false)
      name = nodes.flatten.join('::')
      name.prepend('::') if anchor
      Object.const_get(name)
    rescue NameError
      nil
    end

    def self.is_id?(str)
      str =~ Constants::ONLY_DIGITS || 
      str =~ Constants::UUID
    end

    def self.is_web_exception?(error)
      error.class.ancestors[0].to_s.index('Riff::Exceptions::')
    end

    def self.error_desc(error)
      "#{error.class}: #{error.message}"#\n#{error.backtrace.to_a.join("\n")}"
    end
  end
end

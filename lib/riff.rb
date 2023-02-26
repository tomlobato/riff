# frozen_string_literal: true

require_relative "riff/version"

require_relative 'riff/request_handlers/base'
require_relative 'riff/request_handlers/authentication'
require_relative 'riff/request_handlers/authorization'
require_relative 'riff/request_handlers/action'
require_relative 'riff/request_handlers/check_params'

require_relative 'riff/default_actions/base'
require_relative 'riff/default_actions/list'
require_relative 'riff/default_actions/create'
require_relative 'riff/default_actions/update'
require_relative 'riff/default_actions/show'

require_relative 'riff/request_context'
require_relative 'riff/request_processor'
require_relative 'riff/request_chain'
require_relative 'riff/settings'
require_relative 'riff/util'

require_relative 'riff/version'

module Riff
  class Error < StandardError
  end

  class InvalidPathNodes < StandardError
  end

  class InvalidRequestPath < StandardError
  end

  class UnknownRequestAction < StandardError
  end

  class OutOfBoundsPathNodes < StandardError
  end
end

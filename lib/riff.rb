# frozen_string_literal: true

require 'forwardable'

require_relative "riff/version"

require_relative 'riff/request_handlers/base'
require_relative 'riff/request_handlers/authentication'
require_relative 'riff/request_handlers/authorization'
require_relative 'riff/request_handlers/action'
require_relative 'riff/request_handlers/check_params'

require_relative 'riff/default_actions/base'
require_relative 'riff/default_actions/index'
require_relative 'riff/default_actions/create'
require_relative 'riff/default_actions/update'
require_relative 'riff/default_actions/show'
require_relative 'riff/default_actions/delete'

require_relative 'riff/request_context'
require_relative 'riff/request_processor'
require_relative 'riff/request_chain'
require_relative 'riff/settings'
require_relative 'riff/util'
require_relative 'riff/exceptions'
require_relative 'riff/constants'
require_relative 'riff/set_response'
require_relative 'riff/parse_request'
require_relative 'riff/result'
require_relative 'riff/base_action_settings'
require_relative 'riff/handle_error'

module Riff
end

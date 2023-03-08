# frozen_string_literal: true

require "forwardable"

require_relative "riff/version"

require_relative "riff/request_handlers/base"
require_relative "riff/request_handlers/authentication"
require_relative "riff/request_handlers/authorization"
require_relative "riff/request_handlers/action"
require_relative "riff/request_handlers/check_params"

require_relative "riff/default_actions/helpers/record"
require_relative "riff/default_actions/helpers/attributes"
require_relative "riff/default_actions/helpers/pagination"
require_relative "riff/default_actions/helpers/order"

require_relative "riff/default_actions/base"
require_relative "riff/default_actions/index"
require_relative "riff/default_actions/create"
require_relative "riff/default_actions/update"
require_relative "riff/default_actions/show"
require_relative "riff/default_actions/delete"

require_relative "riff/authentication/create_token"
require_relative "riff/authentication/create_tokens"
require_relative "riff/authentication/update_authentication_token"
require_relative "riff/authentication/message_signer"
require_relative "riff/authentication/token_validator"

require_relative "riff/session/open"
require_relative "riff/session/close"
require_relative "riff/session/refresh"

require_relative "riff/request/parse"
require_relative "riff/request/context"
require_relative "riff/request/action_processor"
require_relative "riff/request/session_processor"
require_relative "riff/request/chain"
require_relative "riff/request/result"
require_relative "riff/request/set_response"

require_relative "riff/base_resource_settings"
require_relative "riff/base_action"
require_relative "riff/base_authorizer"

require_relative "riff/conf"
require_relative "riff/util"
require_relative "riff/constants"
require_relative "riff/validator"
require_relative "riff/exceptions"
require_relative "riff/handle_error"

module Riff
  def self.handle_action(request, response)
    Riff::Request::ActionProcessor.new(request, response).call
  end

  def self.handle_session(request, response, type)
    Riff::Request::SessionProcessor.new(request, response, type).call
  end
end

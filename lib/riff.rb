# frozen_string_literal: true

require "forwardable"

require_relative "riff/version"

require_relative "riff/request_handlers/base"
require_relative "riff/request_handlers/auth"
require_relative "riff/request_handlers/authorization"
require_relative "riff/request_handlers/action"
require_relative "riff/request_handlers/check_params"

require_relative "riff/actions/helpers/record"
require_relative "riff/actions/helpers/attributes"
require_relative "riff/actions/helpers/pagination"
require_relative "riff/actions/helpers/order"
require_relative "riff/actions/helpers/save"

require_relative "riff/actions/base"
require_relative "riff/actions/index"
require_relative "riff/actions/create"
require_relative "riff/actions/update"
require_relative "riff/actions/show"
require_relative "riff/actions/delete"

require_relative "riff/auth/request_auth_method"
require_relative "riff/auth/signin_auth_method"

require_relative "riff/auth/default_method/signin_auth"
require_relative "riff/auth/default_method/request_auth"
require_relative "riff/auth/default_method/token/create_token"
require_relative "riff/auth/default_method/token/create_tokens"
require_relative "riff/auth/default_method/token/message_signer"
require_relative "riff/auth/default_method/token/token_validator"
require_relative "riff/auth/default_method/token/update_auth_token"
require_relative "riff/auth/default_method/token/invalidate_auth_token"
require_relative "riff/auth/default_method/token/util"

require_relative "riff/session/open"
require_relative "riff/session/close"
require_relative "riff/session/refresh"

require_relative "riff/request/remote_ip"
require_relative "riff/request/parse"
require_relative "riff/request/context"
require_relative "riff/request/action_processor"
require_relative "riff/request/session_processor"
require_relative "riff/request/chain"
require_relative "riff/request/result"
require_relative "riff/request/set_response"

require_relative "riff/settings"
require_relative "riff/enable"
require_relative "riff/authorize"
require_relative "riff/base_action"

require_relative "riff/conf"
require_relative "riff/util"
require_relative "riff/constants"
require_relative "riff/validator"
require_relative "riff/exceptions"
require_relative "riff/handle_error"
require_relative "riff/http_verbs"

module Riff
  def self.handle_action(request, response)
    Riff::Request::ActionProcessor.new(request, response).call
  end

  def self.handle_session(request, response, type)
    Riff::Request::SessionProcessor.new(request, response, type).call
  end
end

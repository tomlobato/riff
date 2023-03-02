# frozen_string_literal: true

# This file contains configuration to let the webserver which application to run.

require_relative 'app'

# Enable Rack::Attack
use Rack::Attack

# Rack::URLMap takes a hash mapping urls or paths to apps, and dispatches accordingly.
run Rack::URLMap.new('/' => App.freeze.app)

# frozen_string_literal: true

# This file contains setup for the Riff gem.

Application.boot(:riff) do
  init do
    require 'riff'
  end

  start do
    Riff::Conf.set(:user_class, User)
  end
end

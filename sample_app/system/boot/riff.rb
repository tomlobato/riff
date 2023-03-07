# frozen_string_literal: true

# This file contains setup for the Riff gem.

Application.boot(:riff) do
  init do
    require 'riff'
  end

  start do
    # Configure many
    Riff::Conf.configure(
      user_class: User,
      default_paginate: true,
      default_per_page: 20
    )

    # Configure one
    Riff::Conf.set(:user_class, User)
  end
end

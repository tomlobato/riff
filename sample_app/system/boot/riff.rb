# frozen_string_literal: true

# This file contains setup for the Riff gem.

Application.boot(:riff) do
  init do
    require 'riff'
  end

  start do
    # Configure many
    Riff::Conf.configure(
      default_user_class: User,
      default_paginate: true,
      default_per_page: 20
    )

    # Configure one
    Riff::Conf.set(:default_user_class, User)
  end
end

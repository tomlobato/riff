#!/usr/bin/env ruby

require 'fileutils'
require 'active_support'
require 'active_support/all'

class Skeleton
  def initialize(resources)
    @resources = resources
  end

  def call
    @resources.each do |resource|
      create(resource)
    end
  end

  private

  def create(resource)
    resource_class_name = resource.classify
    base_dir = "app/api/resources/#{resource.singularize}"
    write("#{base_dir}/authorize.rb", authorize(resource_class_name))
    write("#{base_dir}/settings.rb", settings(resource_class_name))
    write("#{base_dir}/enable.rb", enable(resource_class_name))
    write("#{base_dir}/validators/save.rb", validator(resource_class_name, :Save))
    write("#{base_dir}/validators/index.rb", validator(resource_class_name, :Index))
    %w[create show index update delete].each do |action|
      write("#{base_dir}/actions/#{action}.rb", action(resource_class_name, action.classify))
    end
    write("app/models/#{resource.singularize}.rb", model(resource_class_name))
  end

  def write(path, content)
    FileUtils.mkdir_p(File.dirname(path))
    File.write(path, content)
  end

  def authorize(resource_class_name)
    <<~HD
      # frozen_string_literal: true

      module Resources
        module #{resource_class_name}
          class Authorize < Riff::Authorize
          end
        end
      end
    HD
  end

  def settings(resource_class_name)
    <<~HD
      # frozen_string_literal: true

      module Resources
        module #{resource_class_name}
          class Settings < Riff::Settings
          end
        end
      end
    HD
  end

  def enable(resource_class_name)
    <<~HD
      # frozen_string_literal: true

      module Resources
        module #{resource_class_name}
          class Enable < Riff::Enable
          end
        end
      end
    HD
  end

  def validator(resource_class_name, type)
    <<~HD
      # frozen_string_literal: true

      module Resources
        module #{resource_class_name}
          module Validators
            class #{type} < Dry::Validation::Contract
              params do
                required(:param1).value(:string)
                optional(:param2).value(:integer)
              end
      
              rule(:param2) do
                key.failure('must be greater than 0') if value&.negative?
              end
            end
          end
        end
      end
    HD
  end

  def action(resource_class_name, type)
    <<~HD
      # frozen_string_literal: true

      module Resources
        module #{resource_class_name}
          module Actions
            class #{type} < Riff::Actions::#{type}
            end
          end
        end
      end
    HD
  end

  def model(resource_class_name)
    <<~HD
      # frozen_string_literal: true

      class #{resource_class_name} < Sequel::Model
      end
    HD
  end
end

Skeleton.new(ARGV).call

# frozen_string_literal: true

module Riff
  module RequestHandlers
    class CheckParams < Base
      private

      def setup
        @action_validator = action_validator
      end

      def action_validator
        case @context.action
        when 'create', 'update'
          :SaveValidator
        when 'index'
          :IndexParamsValidator
        end
      end

      def class_nodes
        [:Actions, model_name, @action_validator]
      end

      def run
        Validator.new(class_nodes, @context.params).call if @action_validator
      end
    end
  end
end

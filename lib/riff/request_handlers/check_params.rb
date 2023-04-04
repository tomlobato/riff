# frozen_string_literal: true

module Riff
  module RequestHandlers
    class CheckParams < Base
      private

      def setup
        @action_validator = action_validator
      end

      def action_validator
        return if @context.action.to_s.in?(%w[show delete]) 

        @context.action.camelize.to_sym
      end

      def class_nodes
        [:Resources, model_name, :Validators, @action_validator]
      end

      def run
        Validator.new(class_nodes, @context.params, allow_empty_params: allow_empty_params).call if @action_validator
      end

      def allow_empty_params
        @context.action != 'update'
      end
    end
  end
end

# frozen_string_literal: true

module Riff
  module Request
    class ActionProcessor
      def initialize(request, response)
        @request = request
        @response = response
        setup
      end

      def call
        SetResponse.new(@response, call_chain).call
      end

      private

      def setup
        @context = context
        @context.set(:action_class, @action_class = action_class)
        @context.set(:settings, @settings = settings)
      end

      def call_chain
        raise_action_not_found! unless action_available? && @action_class
        Chain.new(@context).call
      rescue StandardError => e
        desc, status = HandleError.new(e).call
        Result.new(desc, status: status)
      end

      def context
        Parse.new(@request).call
      end

      def action_class
        Util.const_get(custom_action, anchor: true) || Util.const_get(default_action)
      end

      def raise_action_not_found!
        Riff::Exceptions::ActionNotFound.create(path, request_method)
      end

      def custom_action
        [:Actions, @context.model_name, @context.action_class_name]
      end

      def default_action
        [:Riff, :DefaultActions, @context.action_class_name]
      end

      def action_available?
        return true if @context.is_custom_method

        !@settings || @settings.__send__("#{@context.action}?")
      end

      def settings_class_path
        [:Actions, @context.model_name, :Settings]
      end

      def settings
        Util.const_get(settings_class_path, anchor: true)&.new || BaseActionSettings.new
      end
    end
  end
end

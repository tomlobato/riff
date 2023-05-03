# frozen_string_literal: true

module Riff
  module Request
    class ActionProcessor
      extend Memo

      def initialize(request, response)
        @request = request
        @response = response
      end

      def call
        SetResponse.new(@response, call_chain).call
      end

      private

      def call_chain
        setup
        raise_action_not_found! unless action_available? && @action_class
        
        Chain.new(@context).call
      rescue StandardError => e
        Util.log_error(e) unless e.is_a?(Riff::Exceptions::RiffError)
        desc, status = HandleError.new(e).call
        Result.new(desc, status: status)
      end

      def setup
        @context = context
        @enabler = enabler
        @context.set(:action_class, @action_class = action_class)
        @context.set(:settings, @settings = settings)
      end

      def context
        Parse.new(@request).call
      end

      def action_class
        custom_action_class || Util.const_get(default_action)
      end

      def custom_action_class
        Util.const_get(custom_action, anchor: true)
      end
      memo :custom_action_class

      def raise_action_not_found!(details: nil)
        raise(Riff::Exceptions::ActionNotFound.create(@context.path, @context.request_method, details: details))
      end

      def custom_action
        [:Resources, @context.model_name, :Actions, @context.action_class_name]
      end

      def default_action
        [:Riff, :Actions, @context.action_class_name]
      end

      def action_available?
        return custom_method_available? if @context.is_custom_method

        !@enabler || @enabler.__send__("#{@context.action}?")
      end

      def custom_method_available?
        return unless custom_action_class
        raise_action_not_found!(details: "Custom method exists but with different http verb") if custom_method_verb_mismatch?

        true
      end

      def custom_method_verb_mismatch?
        "#{custom_action_class}::VERB".constantize != @context.request_method
      end

      def enabler_class_path
        [:Resources, @context.model_name, :Enable]
      end

      def enabler
        Util.const_get(enabler_class_path, anchor: true)&.new || Enable.new
      end

      def settings_class_path
        [:Resources, @context.model_name, :Settings]
      end

      def settings
        Util.const_get(settings_class_path, anchor: true)&.new || Settings.new
      end
    end
  end
end

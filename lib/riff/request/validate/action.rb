# frozen_string_literal: true

module Riff
  module Request
    class Validate
      class Action
        def initialize(context)
          @context = context
        end

        def call
          context.action && 
            action_available? && 
            context.action_class
        end

        private

        attr_reader :context

        def action_available?
          context.custom_method ? custom_method_available? : method_available?
        end

        def method_available?
          !context.enabler || context.enabler.__send__("#{context.action}?")
        end
  
        def custom_method_available?
          return unless context.custom_action_class
  
          if custom_method_verb_mismatch?
            raise_action_not_found!(details: "Custom method exists but with different http verb")
          end
  
          true
        end
  
        def custom_method_verb_mismatch?
          custom_action_verb != @context.request_method
        end
  
        def custom_action_verb
          return @custom_action_verb if defined?(@custom_action_verb)
  
          @custom_action_verb = "#{context.custom_action_class}::VERB".constantize
        rescue NameError
          @custom_action_verb = Riff::HttpVerbs::POST
        end
      end
    end
  end
end

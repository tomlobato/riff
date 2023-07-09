# frozen_string_literal: true

module Riff
  module Request
    class Validate
      def initialize(context)
        @context = context
      end

      def call
        path!
        request_method!
        action!
        custom_method_id!
      end

      private

      attr_reader :context

      def custom_method_id!
        CustomMethodId.new(context).call if context.custom_method
      end

      def action!
        raise(action_not_found) unless Action.new(context).call
      end
      
      def path!
        raise(Riff::Exceptions::OutOfBoundsPathNodes) unless context.path_nodes.size.between?(1, 2)
      end

      def request_method!
        raise(action_not_found(request_method: context.raw_request.request_method)) unless context.request_method
      end

      def action_not_found(request_method: nil)
        Riff::Exceptions::ActionNotFound.create(context.path, request_method || context.request_method)
      end
    end
  end
end

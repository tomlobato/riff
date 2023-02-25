module Riff
  module DefaultActions
    class List < Base
      def initialize(context)
        super
        @scope_class = Util.const_get("Actions::#{@context.model_name}::ListScope")
      end

      def call
        model_klass.where(scope || {})
      end

      private

      def scope
        return unless defined?(@scope_class)

        @scope_class.new(@context).call
      end
    end
  end
end

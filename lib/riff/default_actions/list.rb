module Riff
  module DefaultActions
    class List < Base
      def initialize(context)
        super
        @scope_class = Util.const_get(scope_class_name)
      end

      def call
        model_klass.where(scope || {}).map(&:values)
      end

      private

      def scope
        @scope_class.new(@context).call if defined?(@scope_class)
      end

      def scope_class_name
        "Actions::#{@context.model_name}::ListScope"
      end
    end
  end
end

module Riff
  module DefaultActions
    class Index < Base
      def initialize(context)
        super
        @scope_class = Util.const_get(scope_class_name)
      end

      def call
        body = model_klass.where(scope || {}).map(&:values)
        Result.new(body)
      end

      private

      def scope
        @scope_class.new(@context).call if defined?(@scope_class)
      end

      def scope_class_name
        "Actions::#{@context.model_name}::IndexScope"
      end
    end
  end
end

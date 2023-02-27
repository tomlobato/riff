module Riff
  module DefaultActions
    class Index < Base
      def call
        body = model_klass.where(scope || {}).map(&:values)
        Result.new(body)
      end

      private

      def setup
        @scope_class = Util.const_get(scope_class_name)
      end

      def scope
        @scope_class.new(@context).call if @scope_class
      end

      def scope_class_name
        "Actions::#{@context.model_name}::IndexScope"
      end
    end
  end
end

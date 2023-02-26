module Riff
  module RequestHandlers
    class Authentication < Base
      private

      def run
        @context.set(:logged_user, user_class.new(company_id: 1))
        nil
      end

      def user_class
        Settings.instance.get(:user_class)
      end
    end
  end
end

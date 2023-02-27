module Riff
  module RequestHandlers
    class Authentication < Base
      private

      def run
        @context.set(:logged_user, user)
        nil
      end

      def user_class
        Settings.instance.get(:user_class)
      end

      def user
        u = user_class.new
        u.company_id = 1
        u
      end
    end
  end
end

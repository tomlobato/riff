# frozen_string_literal: true

module Actions
  module Post
    module Actions
      class Stats < Riff::BaseAction
        def call
          Riff::Request::Result.new(body, content_type: 'text/tab-separated-values')
        end

        private

        def body
          (headers + data).each{|line| line.join("\t") }.join("\n")
        end

        def headers
          ['User ID', 'User name', 'Post count']
        end

        def data
          Post
            .join(:users, id: Sequel[:posts][:user_id])
            .where(user_id: @user.id)
            .group(:user_id)
            .order(Sequel.lit('COUNT(posts.id) DESC'))
            .select_map("users.id", "users.name", "COUNT(posts.id)"))
        end
      end
    end
  end
end

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
          (headers + data).map { |line| line.join("\t") }.join("\n")
        end

        def headers
          [['User ID', 'User name', 'Post count']]
        end

        def data
          ::Post
            .join(:users, id: Sequel[:posts][:user_id])
            .where(Sequel[:posts][:company_id] => @user.company_id)
            .group(:user_id)
            .order(Sequel.lit('COUNT(posts.id) DESC'))
            .select(Sequel.lit('users.id, users.name, COUNT(posts.id) AS post_count'))
            .map{|r| [r[:id], r[:name], r[:post_count]] }
        end
      end
    end
  end
end

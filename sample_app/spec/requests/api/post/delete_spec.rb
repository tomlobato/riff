# frozen_string_literal: true

require 'spec_helper'

describe 'DELETE /actions/posts/id', type: :request do
  let!(:user) { create(:user)             }
  let!(:post) { create(:post, user: user) }

  context 'when id is valid' do
    before do
      header 'Authorization', access_token(user)
      delete "/actions/posts/#{post.id}"
    end

    it 'returns 200 HTTP status' do
      expect(response.status).to eq 200
    end

    it 'returns empty response body' do
      expect(response.body).to eq ''
    end

    it 'deletes post' do
      expect(Post.count).to eq 0
    end
  end

  # context 'when id is invalid' do
  #   let(:unexistent_id) { 25_412_342_341_234 }
  #   let(:expected_json) do
  #     {
  #       'details' => "unable to find post with id '#{unexistent_id}'",
  #       'error' => 'Resource not found'
  #     }
  #   end

  #   before do
  #     header 'Authorization', access_token(user)
  #     delete "/actions/posts/#{unexistent_id}"
  #   end

  #   it 'returns 404 HTTP status' do
  #     expect(response.status).to eq 404
  #   end

  #   it 'returns error post in the JSON response' do
  #     expect(json_response).to eq(expected_json)
  #   end
  # end

  # context 'when post belongs to a different user' do
  #   let(:user2) { |i| create(:user, username: "username#{i}") }

  #   let(:expected_json) do
  #     {
  #       'details' => "unable to find post with id '#{post.id}'",
  #       'error' => 'Resource not found'
  #     }
  #   end

  #   before do
  #     header 'Authorization', access_token(user2)
  #     delete "/actions/posts/#{post.id}"
  #   end

  #   it 'returns 404 HTTP status' do
  #     expect(response.status).to eq 404
  #   end

  #   it 'returns error post in the JSON response' do
  #     expect(json_response).to eq(expected_json)
  #   end
  # end
end

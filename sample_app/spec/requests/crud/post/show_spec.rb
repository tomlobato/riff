# frozen_string_literal: true

require 'spec_helper'

describe 'GET /actions/posts/id', type: :request do
  let(:user)  { create(:user)             }
  let!(:post) { create(:post, user: user) }

  context 'when request params are valid' do
    before do
      header 'Authorization', access_token(user)
      get "/actions/posts/#{post.id}"
    end

    it 'returns 200 HTTP status' do
      expect(response.status).to eq 200
    end

    it 'returns user data in the JSON response' do
      expect(json_response['body']).to eq post.body
    end
  end

  context 'when id is invalid' do
    let(:unexistent_id) { 25_412_342_341_234 }

    before do
      header 'Authorization', access_token(user)
      delete "/actions/posts/#{unexistent_id}"
    end

    it 'returns 404 HTTP status' do
      expect(response.status).to eq 404
    end

    it 'returns error post in the JSON response' do
      expected = { 'details' => "unable to find post with id '#{unexistent_id}'", 'error' => 'Resource not found' }
      expect(json_response).to eq(expected)
    end
  end

  context 'when post belongs to a different user' do
    let(:user2) { |i| create(:user, username: "username#{i}") }
    let(:expected_json) do
      {
        'details' => "unable to find post with id '#{post.id}'",
        'error' => 'Resource not found'
      }
    end

    before do
      header 'Authorization', access_token(user2)
      get "/actions/posts/#{post.id}"
    end

    it 'returns 404 HTTP status' do
      expect(response.status).to eq 404
    end

    it 'returns error post in the JSON response' do
      expect(json_response).to eq(expected_json)
    end
  end
end

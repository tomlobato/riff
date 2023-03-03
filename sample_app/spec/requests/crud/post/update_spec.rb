# frozen_string_literal: true

require 'spec_helper'

describe 'PATCH /actions/posts', type: :request do
  let!(:company) { create(:company)                            }
  let!(:user)    { create(:user, company: company)             }
  let!(:post)    { create(:post, user: user, company: company) }

  before do
    header 'Authorization', access_token(user)
    header 'Content-Type', 'application/json'
    patch "/actions/posts/#{post.id}", params.to_json
  end

  context 'when request contains incorrectly formatted params' do
    let(:params) { {} }

    it 'returns 422 HTTP status' do
      expect(response.status).to eq 422
    end

    it 'returns error post in JSON response' do
      expected = { 'error' => 'Invalid parameters', 'messages' => { 'body' => ['is missing'] } }
      expect(json_response).to eq(expected)
    end
  end

  context 'when request params are valid' do
    let(:params) do
      {
        body: 'changed msg body'
      }
    end

    it 'returns 200 HTTP status' do
      expect(response.status).to eq 200
    end

    it 'returns user data in the JSON response' do
      expect(json_response['body']).to eq params[:body]
    end
  end
end

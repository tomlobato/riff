# frozen_string_literal: true

require 'spec_helper'

describe 'POST /actions/posts', type: :request do
  let(:user) { create(:user) }

  before do
    header 'Authorization', access_token(user)
    header 'Content-Type', 'application/json'
    post '/actions/posts', params.to_json
  end

  context 'when request contains incorrectly formatted params' do
    let(:params) { {} }

    it 'returns 422 HTTP status' do
      expect(response.status).to eq 422
    end

    it 'returns error message in JSON response' do
      expected = { 'error' => 'Invalid parameters', 'messages' => { 'body' => ['is missing'] } }
      expect(json_response).to eq(expected)
    end
  end

  context 'when request params are valid' do
    let(:params) do
      {
        body: 'post body'
      }
    end
    let(:keys_to_check) { params.keys.map(&:to_s) }
    let(:message_json_response) do
      params.stringify_keys
    end

    it 'returns 200 HTTP status' do
      expect(response.status).to eq 200
    end

    it 'returns user data in the JSON response' do
      expect(json_response.slice(*keys_to_check)).to eq message_json_response
    end
  end
end

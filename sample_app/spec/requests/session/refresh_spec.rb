# frozen_string_literal: true

require 'spec_helper'

describe 'POST /session/refresh', type: :request do
  let(:user) { create(:user) }

  include_examples 'authorization check', 'post', '/session/refresh'

  context 'when Authorization headers contains valid refresh token' do
    let(:tokens) do
      {
        'access_token' => {
          'token' => 'authorization_token',
          'expires_in' => 300
        },

        'refresh_token' => {
          'token' => 'refresh_token',
          'expires_in' => 900
        }
      }
    end

    before do
      header 'Authorization', refresh_token(user)

      post '/session/refresh'
    end

    it 'returns 200 HTTP status' do
      expect(response.status).to eq 200
    end

    it 'returns new authorization and refresh token in the JSON response' do
      expect(json_response['tokens']['access_token']['token']).to be_present
      expect(json_response['tokens']['access_token']['token'].size).to be >= 200
      expect(json_response['tokens']['refresh_token']['token']).to be_present
      expect(json_response['tokens']['refresh_token']['token'].size).to be >= 200
      expect(replace_tokens(json_response)).to eq('tokens' => tokens)
    end
  end

  context 'when Authorization headers contains valid authorization token with invalid purpose' do
    before do
      header 'Authorization', access_token(user)

      post '/session/refresh'
    end

    include_examples 'unauthorized'
  end
end

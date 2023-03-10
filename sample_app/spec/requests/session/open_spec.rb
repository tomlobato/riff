# frozen_string_literal: true

require 'spec_helper'

describe 'POST /session/login', type: :request do
  context 'when request contains incorrectly formatted params' do
    let(:expected_json_response) do
      {
        'error' => 'Invalid parameters',
        'messages' => { 'password' => 'is missing', 'username' => 'is missing' }
      }
    end

    before { post '/session/login' }

    it 'returns 422 HTTP status' do
      expect(response.status).to eq 422
    end

    it 'returns error message in JSON response' do
      expect(json_response).to eq(expected_json_response)
    end
  end

  context 'when username or password are invalid' do
    let(:params) { { username: 'wrong@email.com', password: 'wrong-password' } }
    let(:expected_json_response) do
      {
        'details' => 'Riff::Exceptions::InvalidEmailOrPassword',
        'error' => 'Invalid email or password'
      }
    end

    before { post '/session/login', params }

    it 'returns 401 status' do
      expect(response.status).to eq 401
    end

    it 'returns error message in JSON response' do
      expect(json_response).to eq(expected_json_response)
    end
  end

  context 'when username and password are valid' do
    let(:user)   { create(:user) }
    let(:params) { { username: user.username, password: 'password' } }

    let(:authorization_tokens_generator) do
      instance_double(Riff::Authentication::CreateTokens)
    end

    let(:tokens) do
      {
        'access_token' => {
          'token' => 'authorization_token',
          'expires_in' => 1800
        },

        'refresh_token' => {
          'token' => 'refresh_token',
          'expires_in' => 3600
        }
      }
    end

    let(:login_json_response) do
      {
        'user' => {
          'id' => user.id,
          'name' => user.name,
          'email' => user.email
        },

        'tokens' => tokens
      }
    end

    before do
      expect(Riff::Authentication::CreateTokens)
        .to receive(:new)
        .with(user)
        .and_return(authorization_tokens_generator)

      expect(authorization_tokens_generator)
        .to receive(:call)
        .and_return(tokens)

      post '/session/login', params
    end

    it 'returns 200 status' do
      expect(response.status).to eq 200
    end

    it 'returns user data with its access and refresh token informations in the JSON response' do
      expect(json_response).to eq login_json_response
    end
  end

  context 'when session action is invalid' do
    let(:expected_json) do
      {
        'details' => "'invalid_action' is not a valid session action",
        'error' => 'Invalid request path'
      }
    end

    before { post '/session/invalid_action', {} }

    it 'returns 422 status' do
      expect(response.status).to eq 422
    end

    it 'returns error message in JSON response' do
      expect(json_response).to eq(expected_json)
    end
  end
end

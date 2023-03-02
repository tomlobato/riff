# frozen_string_literal: true

require 'spec_helper'

describe 'POST /actions/users', type: :request do
  let(:user) { create(:user) }

  before do
    header 'Authorization', access_token(user)
    post '/actions/users', params
  end

  context 'when request contains incorrectly formatted params' do
    let(:params) { {} }

    it 'returns 422 HTTP status' do
      expect(response.status).to eq 422
    end

    it 'returns error message in JSON response' do
      expected = {
        'error' => 'Invalid parameters',
        'messages' => { 'company_id' => ['is missing'], 'email' => ['is missing'] }
      }
      expect(json_response).to eq(expected)
    end
  end

  context 'when request params are valid' do
    let(:params) do
      {
        email: 'asd@asd.com',
        password: 'password',
        password_confirmation: 'password',
        authentication_token: SecureRandom.hex(40),
        company_id: user.company_id,
        name: "John",
        username: "john",
        is_admin: true,
      }
    end
    let(:keys_to_check) { params.keys.map(&:to_s) }
    let(:user_json_response) do
      r = params.stringify_keys
      r.delete('password')
      r.delete('password_confirmation')
      r
    end

    it 'returns 200 HTTP status' do
      expect(response.status).to eq 200
    end

    it 'returns user data in the JSON response' do
      expect(json_response.slice(*keys_to_check)).to eq user_json_response
    end
  end
end

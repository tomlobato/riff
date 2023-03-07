# frozen_string_literal: true

require 'spec_helper'

describe 'PATCH /actions/users', type: :request do
  let(:user) { create(:user) }

  before do
    header 'Authorization', access_token(user)
    header 'Content-Type', 'application/json'
    patch "/actions/users/#{user.id}", params.to_json
  end

  context 'when request params are valid' do
    let(:params) do
      {
        email: 'asd@asd.com',
        password: 'password',
        password_confirmation: 'password',
        authentication_token: SecureRandom.hex(40),
        company_id: user.company_id,
        name: 'John',
        username: 'john',
        is_admin: true
      }
    end

    it 'returns 403 HTTP status' do
      expect(response.status).to eq 403
    end

    it 'returns correct error body' do
      expect(json_response).to eq({"details"=>"Riff::Exceptions::AuthorizationFailure", "error"=>"Authorization failure"})
    end
  end
end

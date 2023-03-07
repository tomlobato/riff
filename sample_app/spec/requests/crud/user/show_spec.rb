# frozen_string_literal: true

require 'spec_helper'

describe 'GET /actions/users/id', type: :request do
  let(:user) { create(:user) }

  before do
    header 'Authorization', access_token(user)
    header 'Content-Type', 'application/json'
    get "/actions/users/#{user.id}"
  end

  context 'when request params are valid' do
    let(:expected_json) do
      {
        'details' => "Authorization result must be one of true, false, nil or a hash. We got a 'String'.",
        'error' => 'Invalid authorization result'
      }
    end

    it 'returns 500 HTTP status' do
      expect(response.status).to eq 500
    end

    it 'returns correct error body' do
      expect(json_response).to eq(expected_json)
    end
  end
end

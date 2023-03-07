# frozen_string_literal: true

require 'spec_helper'

describe 'POST /actions/companies', type: :request do
  let(:user) { create(:user) }

  before do
    header 'Authorization', access_token(user)
    header 'Content-Type', 'application/json'
    post '/actions/companies', params.to_json
  end

  context 'when request contains incorrectly formatted params' do
    let(:params) { {} }
    let(:expected_json) do
      {
        "error" => "Db validation error", 
        "messages"=>{"name"=>["is not present"]}
      }
    end

    it 'returns 422 HTTP status' do
      expect(response.status).to eq 422
    end

    it 'returns error message in JSON response' do
      expect(json_response).to eq(expected_json)
    end
  end
end

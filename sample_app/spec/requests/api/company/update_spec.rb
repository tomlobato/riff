# frozen_string_literal: true

require 'spec_helper'

describe 'PATCH /actions/companies', type: :request do
  let(:company) { create(:company)                }
  let(:user)    { create(:user, company: company) }

  before do
    header 'Authorization', access_token(user)
    header 'Content-Type', 'application/json'
    patch "/actions/companies/#{company.id}", params.to_json
  end

  context 'when request params are valid' do
    let(:params) do
      {
        name: 'Other company'
      }
    end
    let(:expected_json) do
      {
        'details' => 'Riff::Exceptions::AuthorizationFailure',
        'error' => 'Authorization failure'
      }
    end

    it 'returns 403 HTTP status' do
      expect(response.status).to eq 403
    end

    it 'returns correct error body' do
      expect(json_response).to eq(expected_json)
    end
  end
end

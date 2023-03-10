# frozen_string_literal: true

require 'spec_helper'

describe 'DELETE /actions/users', type: :request do
  let(:user) { create(:user) }

  before do
    header 'Authorization', access_token(user)
    header 'Content-Type', 'application/json'
    delete "/actions/users/#{user.id}"
  end

  context 'when action returs wrong body type' do
    it 'returns 500 HTTP status' do
      expect(response.status).to eq 500
    end

    it 'returns correct error body' do
      expect(json_response).to eq({ 'details' => "Unhandled body class 'Integer'", 'error' => 'Invalid response body' })
    end
  end
end

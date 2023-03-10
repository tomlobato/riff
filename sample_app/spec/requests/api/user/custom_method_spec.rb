# frozen_string_literal: true

require 'spec_helper'

describe 'GET /actions/users/:custom_method', type: :request do
  let!(:user) { create(:user) }

  context 'when custom_method is valid but raises an exception' do
    before do
      header 'Authorization', access_token(user)
      get '/actions/users/:custom_method'
    end

    it 'returns 500 HTTP status' do
      expect(response.status).to eq 500
    end

    it 'returns user data in the JSON response' do
      expect(json_response).to eq({ 'details' => 'test error', 'error' => 'Error executing requested operation' })
    end
  end

  context 'when custom_method has not implemented customization' do
    before do
      header 'Authorization', access_token(user)
      get '/actions/users/:custom_method2'
    end

    it 'returns 500 HTTP status' do
      expect(response.status).to eq 500
    end

    it 'returns user data in the JSON response' do
      expect(json_response).to eq({ 'details' => 'Riff::Exceptions::NotImplemented', 'error' => 'Not implemented' })
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

describe 'GET /actions/users', type: :request do
  let!(:user)        { create(:user)                  }
  let(:slice_fields) { %w[id user_id company_id body] }

  before do
    header 'Authorization', access_token(user)
    get(url)
  end

  context 'when request has no id' do
    let(:url) { '/actions/users' }

    it 'returns 200 HTTP status' do
      expect(response.status).to eq 200
    end

    it 'response contains correct body' do
      expect(json_response.map { |i| i.slice(*slice_fields) }).to eq [user.values.stringify_keys.slice(*slice_fields)]
    end
  end

  context 'when pagination is tried but disabled' do
    let(:url) { '/actions/users?_page=2' }

    it 'returns 422 HTTP status' do
      expect(response.status).to eq 422
    end

    it 'response contains correct body' do
      expect(json_response).to eq({ 'error' => 'Invalid parameters', 'messages' => { '_page' => '2' } })
    end
  end

  context 'when order refers to unexistent column' do
    let(:url) { '/actions/users?_order=non_existent_column' }

    it 'returns 422 HTTP status' do
      expect(response.status).to eq 422
    end

    it 'response contains correct body' do
      expect(json_response).to eq({ 'error' => 'Invalid parameters', 'messages' => { 'order' => 'non_existent_column' } })
    end
  end
end

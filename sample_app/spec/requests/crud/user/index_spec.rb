# frozen_string_literal: true

require 'spec_helper'

describe 'GET /actions/users', type: :request do
  let!(:user) { create(:user) }
  let(:slice_fields) { %w[id user_id company_id body] }

  before do
    header 'Authorization', access_token(user)
    get('/actions/users')
  end

  it 'returns 200 HTTP status' do
    expect(response.status).to eq 200
  end

  it 'response contains correct body' do
    expect(json_response.map { |i| i.slice(*slice_fields) }).to eq [user.values.stringify_keys.slice(*slice_fields)]
  end
end

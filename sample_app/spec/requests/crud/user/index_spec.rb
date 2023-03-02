# frozen_string_literal: true

require 'spec_helper'

describe 'GET /actions/users', type: :request do
  let!(:user) { create(:user) }

  before do
    header 'Authorization', access_token(user)
    get('/actions/users')
  end

  it 'returns 200 HTTP status' do
    expect(response.status).to eq 200
  end

  it 'response contains correct body' do
    expect(json_response.map { |o| remove_dates(o) }).to eq [remove_dates(user.values.stringify_keys)]
  end
end

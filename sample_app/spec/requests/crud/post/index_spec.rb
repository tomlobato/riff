# frozen_string_literal: true

require 'spec_helper'

describe 'GET /actions/posts', type: :request do
  let(:user)  { create(:user)             }
  let!(:post) { create(:post, user: user) }

  before do
    header 'Authorization', access_token(user)
    get('/actions/posts')
  end

  it 'returns 200 HTTP status' do
    expect(response.status).to eq 200
  end

  it 'response contains correct body' do
    expect(response.body).to eq Oj.dump([post.values])
  end
end

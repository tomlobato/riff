# frozen_string_literal: true

require 'spec_helper'

describe 'GET /actions/posts/:custom_method', type: :request do
  let!(:company) { create(:company)                                }
  let!(:user)    { create(:user, company: company, is_admin: true) }
  let!(:user2)   { create(:user, company: company)                 }

  before do
    create(:post, user: user, company: company)
    create(:post, user: user, company: company)
    create(:post, user: user2, company: company)
    create(:post, user: user2, company: company)
    create(:post, user: user2, company: company)
  end

  context 'when custom_method is valid' do
    before do
      header 'Authorization', access_token(user)
      get '/actions/posts/:stats'
    end

    it 'returns 200 HTTP status' do
      expect(response.status).to eq 200
    end

    it 'returns user data in the JSON response' do
      expect(response.body).to eq "User ID\tUser name\tPost count\n#{user2.id}\tJohn Wayne\t3\n#{user.id}\tJohn Wayne\t2"
    end
  end

  context 'when custom_method is not valid' do
    let(:expected_json) do
      {
        'details' => "path='/actions/posts/:non_existent_custom_method' verb='GET'",
        'error' => 'Action not found'
      }
    end

    before do
      header 'Authorization', access_token(user)
      get '/actions/posts/:non_existent_custom_method'
    end

    it 'returns 404 HTTP status' do
      expect(response.status).to eq 404
    end

    it 'returns blank body' do
      expect(json_response).to eq(expected_json)
    end
  end
end

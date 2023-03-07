# frozen_string_literal: true

require 'spec_helper'

describe 'PATCH /actions/posts', type: :request do
  let!(:company) { create(:company)                            }
  let!(:user)    { create(:user, company: company)             }
  let!(:post)    { create(:post, user: user, company: company) }

  before do
    header 'Authorization', access_token(user)
    header 'Content-Type', 'application/json'
    patch url, params.to_json
  end

  context 'when request contains incorrectly formatted params' do
    let(:params) { {} }
    let(:url) { "/actions/posts/#{post.id}" }

    it 'returns 422 HTTP status' do
      expect(response.status).to eq 422
    end

    it 'returns error post in JSON response' do
      expected = { 'error' => 'Invalid parameters', 'messages' => { 'body' => ['is missing'] } }
      expect(json_response).to eq(expected)
    end
  end

  context 'when request params are valid' do
    let(:params) do
      {
        body: 'changed msg body'
      }
    end
    let(:url) { "/actions/posts/#{post.id}" }

    it 'returns 200 HTTP status' do
      expect(response.status).to eq 200
    end

    it 'returns user data in the JSON response' do
      expect(json_response['body']).to eq params[:body]
    end
  end

  context 'when request has no id' do
    let(:params) do
      {
        body: 'changed post body'
      }
    end
    let(:url) { '/actions/posts' }

    it 'returns 404 HTTP status' do
      expect(response.status).to eq 404
    end

    it 'returns user data in the JSON response' do
      expect(json_response).to eq({ 'details' => "path='/actions/posts' verb='PATCH'", 'error' => 'Action not found' })
    end
  end

  context 'when request has unpermitted param' do
    let(:params) do
      {
        body: 'changed post body',
        title: 'changed post title',
        company_id: 123_456_789
      }
    end
    let(:url) { "/actions/posts/#{post.id}" }

    it 'returns 422 HTTP status' do
      expect(response.status).to eq 422
    end

    it 'returns user data in the JSON response' do
      expect(json_response).to eq({ 'error' => 'Invalid parameters', 'messages' => { 'company_id' => params[:company_id] } })
    end
  end

  context 'when request required param blank' do
    let(:params) do
      {
        body: 'changed msg body',
        title: nil
      }
    end
    let(:url) { "/actions/posts/#{post.id}" }

    it 'returns 422 HTTP status' do
      expect(response.status).to eq 422
    end

    it 'returns user data in the JSON response' do
      expect(json_response).to eq({ 'error' => 'Db validation error', 'messages' => 'title is not present' })
    end
  end
end

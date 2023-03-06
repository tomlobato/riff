# frozen_string_literal: true

require 'spec_helper'

describe 'GET /actions/posts', type: :request do
  let(:company) { create(:company)                                  }
  let(:user)    { create(:user, company: company)                   }
  let!(:post)   { create(:post, user: user, company: company)       }
  let!(:post2)  { create(:post, user: user, company: company)       }
  let!(:post3)  { create(:post, user: user, company: company)       }
  let!(:ordered_ids)  { [post.id, post2.id, post3.id] }

  before do
    header 'Authorization', access_token(user)
    get(url)
  end

  context 'when request is valid' do
    let(:url) { '/actions/posts' }
    let(:slice_fields) { %w[id user_id company_id body] }
    let(:expected_response) do
      [post, post2, post3].map{ |p| p.values.slice(*slice_fields.map(&:to_sym)).stringify_keys }
    end
  
    it 'returns 200 HTTP status' do
      expect(response.status).to eq 200
    end

    it 'response contains correct body' do
      expect(json_response.map{ |i| i.slice(*slice_fields) }).to eq expected_response
    end
  end

  context 'when request is ordered by id' do
    let(:url) { '/actions/posts?_order=id' }

    it 'returns 200 HTTP status' do
      expect(response.status).to eq 200
    end

    it 'response contains ordered items' do
      expect(extract_field(json_response, 'id')).to eq ordered_ids
    end
  end

  context 'when request is ordered by id:desc' do
    let(:url) { '/actions/posts?_order=id:desc' }

    it 'returns 200 HTTP status' do
      expect(response.status).to eq 200
    end

    it 'response contains ordered items' do
      expect(extract_field(json_response, 'id')).to eq ordered_ids.reverse
    end
  end

  context 'when request has limit' do
    let(:url) { '/actions/posts?_limit=2' }

    it 'returns 200 HTTP status' do
      expect(response.status).to eq 200
    end

    it 'response contains ordered items' do
      expect(json_response.size).to eq 2
    end
  end

  context 'when request has page/limit' do
    let(:url) { '/actions/posts?_page=2&_limit=2' }

    it 'returns 200 HTTP status' do
      expect(response.status).to eq 200
    end

    it 'response contains ordered items' do
      expect(json_response[0]['id'].to_i).to eq post3.id
    end
  end

  context 'when request has page/limit and order' do
    let(:url) { '/actions/posts?_page=2&_limit=2&_order=id:desc' }

    it 'returns 200 HTTP status' do
      expect(response.status).to eq 200
    end

    it 'response contains ordered items' do
      expect(json_response[0]['id'].to_i).to eq post.id
    end
  end
end

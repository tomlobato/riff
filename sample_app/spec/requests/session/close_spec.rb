# frozen_string_literal: true

require 'spec_helper'

describe 'POST /session/logout', type: :request do
  include_examples 'authorization check', 'post', '/session/logout'

  context 'when Authorization headers contains valid token' do
    let(:user) { create(:user) }

    let(:update_auth_token) do
      instance_double(Riff::Auth::DefaultMethod::Token::UpdateAuthToken)
    end

    before do
      expect(Riff::Auth::DefaultMethod::Token::UpdateAuthToken)
        .to receive(:new)
        .with(user)
        .and_return(update_auth_token)

      expect(update_auth_token)
        .to receive(:call)

      header 'Authorization', access_token(user)

      post '/session/logout'
    end

    it 'returns 200 HTTP status' do
      expect(response.status).to eq 200
    end

    it 'returns empty response body' do
      expect(response.body).to eq ''
    end
  end
end

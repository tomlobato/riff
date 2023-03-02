# frozen_string_literal: true

require 'spec_helper'

describe 'POST /session/sign_out', type: :request do
  include_examples 'authorization check', 'post', '/session/sign_out'

  context 'when Authorization headers contains valid token' do
    let(:user) { create(:user) }

    let(:update_authentication_token) do
      instance_double(Riff::Authentication::UpdateAuthenticationToken)
    end

    before do
      expect(Riff::Authentication::UpdateAuthenticationToken)
        .to receive(:new)
        .with(user)
        .and_return(update_authentication_token)

      expect(update_authentication_token)
        .to receive(:call)

      header 'Authorization', access_token(user)

      post '/session/sign_out'
    end

    it 'returns 200 HTTP status' do
      expect(response.status).to eq 200
    end

    it 'returns empty response body' do
      expect(response.body).to eq ''
    end
  end
end

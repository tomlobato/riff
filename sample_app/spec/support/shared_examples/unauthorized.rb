# frozen_string_literal: true

RSpec.shared_examples 'unauthorized' do
  let(:expected_json_response) do
    {
      'details' => 'Riff::Exceptions::AuthFailure',
      'error' => 'Auth failure'
    }
  end

  it 'returns 401 HTTP status' do
    expect(response.status).to eq 401
  end

  it 'returns error message in the JSON response' do
    expect(json_response).to eq(expected_json_response)
  end
end

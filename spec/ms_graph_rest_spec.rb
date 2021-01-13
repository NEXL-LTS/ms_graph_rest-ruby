RSpec.describe MsGraphRest do
  it 'has a version number' do
    expect(MsGraphRest::VERSION).not_to be nil
  end

  describe MsGraphRest::Client do
    context 'when resource not found' do
      subject { described_class.new(access_token: 'access_token') }

      before {
        allow(subject.conn).to receive(:get).and_raise(Faraday::ResourceNotFound.new("Error"))
      }

      it 'raises error' do
        expect { subject.get('path', {}) }.to raise_error(MsGraphRest::ResourceNotFound)
      end
    end
  end
end

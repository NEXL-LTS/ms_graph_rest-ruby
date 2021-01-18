require 'spec_helper'

module MsGraphRest
  RSpec.describe Photos do
    subject { Photos.new(client: client) }

    let(:client) { double }
    let(:response) { double }

    before { 
      allow(response).to receive(:body).and_return('image')
      allow(client).to receive(:get_raw).and_return(response)
    }

    it{
      expect(subject.get('bapu@nexl.io')).to eq('image')
    }
  end
end

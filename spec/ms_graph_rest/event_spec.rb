require 'spec_helper'

module MsGraphRest
  RSpec.describe 'Event' do
    let(:client) { MsGraphRest.new_client(access_token: "access_token") }
    let(:event_query) { client.event(path) }

    describe 'Get single message' do
      let(:path) { 'me' }
      let(:event_id) { 'event_id' }
      let(:body) { { 'itemId' => 'Item Id', 'iCalUid' => 'Calendar Uid' }.to_json }

      before do
        stub_request(:get, "https://graph.microsoft.com/v1.0/me/events/#{event_id}").to_return(status: 200, body: body, headers: {})
      end

      it do
        result = event_query.get(event_id)
        expect(result).to have_attributes(itemId: "Item Id", 'iCalUid' => 'Calendar Uid')
      end
    end
  end
end

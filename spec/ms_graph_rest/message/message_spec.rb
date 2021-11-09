require 'spec_helper'

module MsGraphRest
  RSpec.describe 'Message' do
    let(:client) { MsGraphRest.new_client(access_token: "123") }
    let(:message_query) { client.message(path) }

    describe 'Get single message' do
      let(:path) { 'me' }
      let(:message_id) { 'mi' }
      let(:body) { File.read("#{__dir__}/default.json") }

      before do
        stub_request(:get, "https://graph.microsoft.com/v1.0/me/messages/#{message_id}")
          .to_return(status: 200, body: body, headers: {})
      end

      it do
        result = message_query.get(message_id)
        expect(result).to have_attributes(id: "AAMkADhMGAAA=", subject: "9/9/2018: concert")
        expect(result.sender.email_address)
          .to have_attributes(name: "Adele Vance", address: "adelev@contoso.OnMicrosoft.com")
      end
    end

    describe 'using select' do
      let(:path) { 'me' }
      let(:message_id) { 'mi' }
      let(:body) { File.read("#{__dir__}/select.json") }

      before do
        stub_request(:get, "https://graph.microsoft.com/v1.0/me/messages/#{message_id}?$select=internetMessageHeaders")
          .to_return(status: 200, body: body, headers: {})
      end

      it do
        result = message_query.select(['internetMessageHeaders']).get(message_id)
        expect(result.internet_message_headers.size).to eq(4)
        expect(result.internet_message_headers.first)
          .to have_attributes(name: "MIME-Version", value: "1.0")
      end
    end
  end
end

require 'spec_helper'

module MsGraphRest
  RSpec.describe 'Messages' do
    let(:client) { MsGraphRest.new_client(access_token: "123") }
    let(:messages) { client.messages(path) }

    describe 'Get top 10 messages with select' do
      let(:path) { 'me' }
      let(:body) { File.read("#{__dir__}/messages_default.json") }

      before do
        params = "$select=sender,subject"
        stub_request(:get, "https://graph.microsoft.com/v1.0/me/messages?#{params}")
          .to_return(status: 200, body: body, headers: {})
      end

      it do
        result = messages.select([:sender, :subject]).get
        expect(result.size).to eq(10)
        expect(result.first).to have_attributes(id: "AAMkAGUAAAwTW09AAA=", subject: "You have late tasks!")
        expect(result.first.sender.email_address)
          .to have_attributes(name: "Microsoft Planner", address: "noreply@Planner.Office365.com")
      end

      it 'returns for next link' do
        result = messages.select([:sender, :subject]).get
        expect(result.odata_next_link).to eq("https://graph.microsoft.com/v1.0/me/messages?$select=sender%2csubject&$skip=14")
        expect(result.next_get_query).to eq(select: 'sender,subject', skip: "14")

        params = "$select=sender,subject&$skip=14"
        stub_request(:get, "https://graph.microsoft.com/v1.0/me/messages?#{params}")
          .to_return(status: 200, body: "{}", headers: {})
        messages.get(**result.next_get_query)
      end
    end

    describe 'Get with filter and order by' do
      let(:path) { 'users/person@example.com' }
      let(:body) { File.read("#{__dir__}/messages_filter.json") }

      before do
        params = "$filter=createdDateTime%20ge%202020-01-12T22:39:15Z&$orderBy=createdDateTime%20asc"
        stub_request(:get, "https://graph.microsoft.com/v1.0/users/person@example.com/messages?#{params}")
          .to_return(status: 200, body: body, headers: {})
      end

      it do
        result = messages.filter("createdDateTime ge 2020-01-12T22:39:15Z")
                         .order_by('createdDateTime asc')
                         .get
        expect(result.size).to eq(10)
        expect(result.first).to have_attributes(id: "AAMkAGUAAAwTW09AAA=", subject: "You have late tasks!")
        expect(result.first.sender.email_address)
          .to have_attributes(name: "Microsoft Planner", address: "noreply@Planner.Office365.com")
      end

      it 'returns for next link' do
        result = messages.filter("createdDateTime ge 2020-01-12T22:39:15Z")
                         .order_by('createdDateTime asc')
                         .get
        expect(result.next_get_query).to eq(skip: "10", top: "10",
                                            order_by: 'createdDateTime asc',
                                            filter: "createdDateTime ge 2020-01-12T22:39:15Z")

        params = "$filter=createdDateTime%20ge%202020-01-12T22:39:15Z&$orderBy=createdDateTime%20asc&$skip=10&$top=10"
        stub_request(:get, "https://graph.microsoft.com/v1.0/users/person@example.com/messages?#{params}")
          .to_return(status: 200, body: "{}", headers: {})
        messages.get(**result.next_get_query)
      end
    end
  end
end

require 'spec_helper'

module MsGraphRest
  RSpec.describe 'Contacts' do
    let(:client) { MsGraphRest.new_client(access_token: "123") }
    let(:contacts) { client.contacts(path) }

    describe 'Get top 10 contacts with select' do
      let(:path) { 'me' }
      let(:body) { File.read("#{__dir__}/contacts_default.json") }

      before do
        params = "$select=givenName,surname"
        stub_request(:get, "https://graph.microsoft.com/v1.0/me/contacts?#{params}")
          .to_return(status: 200, body: body, headers: {})
      end

      it do
        result = contacts.select([:given_name, :surname]).get
        expect(result.value.size).to eq(10)
        expect(result.value.first).to have_attributes(given_name: "Alex", surname: "Wilber")
        expect(result.value.first.email_addresses.first)
          .to have_attributes(address: "Alex@FineArtSchool.net", name: "Alex@FineArtSchool.net")
      end

      it 'returns for next link' do
        result = contacts.select([:given_name, :surname]).get
        expect(result.odata_next_link).to eq("https://graph.microsoft.com/v1.0/me/contacts?%24skip=10")
        expect(result.next_get_query).to eq(skip: "10")

        params = "$skip=10"
        stub_request(:get, "https://graph.microsoft.com/v1.0/me/contacts?#{params}")
          .to_return(status: 200, body: "{}", headers: {})
        contacts.get(**result.next_get_query)
      end
    end

    describe 'Create contact' do
      let(:path) { 'me' }
      let(:contact_id) { 'AAMkAGI2THk0AAA=' }
      let(:body) { File.read("#{__dir__}/update_contact_example.json") }
      let(:payload) { { given_name: "Alex", surname: "Wilber" } }

      before do
        stub_request(:post, "https://graph.microsoft.com/v1.0/me/contacts/")
          .to_return(status: 200, body: body, headers: {})
      end

      it do
        result = contacts.create(payload)
        expect(result).to have_attributes(given_name: "Alex", surname: "Wilber")
      end
    end

    describe 'Update contact' do
      let(:path) { 'me' }
      let(:contact_id) { 'AAMkAGI2THk0AAA=' }
      let(:body) { File.read("#{__dir__}/update_contact_example.json") }
      let(:payload) { { given_name: "Alex", surname: "Wilber" } }

      before do
        stub_request(:patch, "https://graph.microsoft.com/v1.0/me/contacts/#{contact_id}")
          .to_return(status: 200, body: body, headers: {})
      end

      it do
        result = contacts.update(contact_id, payload)
        expect(result).to have_attributes(given_name: "Alex", surname: "Wilber")
      end
    end

    describe 'finding by email' do
      let(:path) { 'me' }
      let(:body) { File.read("#{__dir__}/contacts_filtered.json") }

      before do
        params = "$filter=emailAddresses/any(a:a/address+eq+'Alex''d@FineArtSchool.net')"
        stub_request(:get, "https://graph.microsoft.com/v1.0/me/contacts?#{params}")
          .to_return(status: 200, body: body, headers: {})
      end

      it do
        result = contacts.filter_email('Alex\'d@FineArtSchool.net').get
        expect(result.value.size).to eq(1)
      end
    end
  end
end

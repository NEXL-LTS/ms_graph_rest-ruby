require 'spec_helper'

module MsGraphRest
  RSpec.describe 'Group Members' do
    let(:client) { MsGraphRest.new_client(access_token: "123") }
    let(:group_id) { 'group_id' }
    let(:group_members) { client.group_members(group_id) }

    describe 'Get all group members' do
      before do
        stub_request(:get, "https://graph.microsoft.com/v1.0/groups/#{group_id}/members")
          .to_return(status: 200, body: body, headers: {})
      end

      let(:body) do
        IO.read(__dir__+'/group_members.json')
      end

      it do
        result = group_members.get
        expect(result.size).to eq(19)
        expect(result.first)
          .to have_attributes(id: "87d349ed-44d7-43e1-9a83-5f2406dee5bd", 
                              business_phones: ["+1 425 555 0109"],
                              display_name: "Adele Vance",
                              given_name: "Adele",
                              surname: "Vance",
                              job_title: "Product Marketing Manager",
                              mail: "AdeleV@M365x214355.onmicrosoft.com",
                              mobile_phone: nil,
                              office_location: "18/2111",
                              preferred_language: "en-US",
                              user_principal_name: "AdeleV@M365x214355.onmicrosoft.com"
                             )
      end
    end
  end
end
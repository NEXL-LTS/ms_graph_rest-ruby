require 'spec_helper'

module MsGraphRest
  RSpec.describe 'Group Members' do
    let(:client) { MsGraphRest.new_client(access_token: "123") }
    let(:group_id) { 'group_id' }
    let(:group_members) { client.group_members(group_id) }

    describe 'Get all group members' do
      let(:body) do
        File.read(__dir__ + '/group_member_response/group_members.json')
      end

      let(:next_body) do
        File.read(__dir__ + '/group_member_response/group_members_next.json')
      end

      before do
        stub_request(:get, "https://graph.microsoft.com/v1.0/groups/#{group_id}/members?$top=10")
          .to_return(status: 200, body: body, headers: {})

        stub_request(:get, "https://graph.microsoft.com/v1.0/groups/#{group_id}/members?\
$skiptoken=RFNwdAoAAQAAAAAAAAAAFAAAAPvqzxAdXd9LnQAjIxwK_TMBAAAAAAAAAAAAAAAAAAAXMS4yLjg0MC\
4xMTM1NTYuMS40LjIzMzEGAAAAAAAByim_TWUbpEG9TbvKE2Y3dgF2AAAAAQEAAAA&$top=10")
          .to_return(status: 200, body: next_body, headers: {})
      end

      it do
        result = group_members.get(top: 10)
        expect(result.size).to eq(10)
        expect(result.first)
          .to have_attributes(id: "87d349ed-44d7-43e1-9a83-5f2406dee5bd", business_phones: ["+1 425 555 0109"],
                              display_name: "Adele Vance", given_name: "Adele", surname: "Vance",
                              job_title: "Product Marketing Manager",
                              mail: "AdeleV@M365x214355.onmicrosoft.com",
                              mobile_phone: nil, office_location: "18/2111",
                              preferred_language: "en-US",
                              user_principal_name: "AdeleV@M365x214355.onmicrosoft.com")

        next_result = group_members.get(**result.next_get_query)
        expect(next_result.size).to be(9)
      end
    end
  end
end

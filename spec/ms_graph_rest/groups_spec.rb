require 'spec_helper'

module MsGraphRest
  RSpec.describe 'Groups' do
    let(:client) { MsGraphRest.new_client(access_token: "123") }
    let(:groups) { client.groups }

    describe 'Get all groups' do
      before do
        stub_request(:get, "https://graph.microsoft.com/v1.0/groups")
          .to_return(status: 200, body: body, headers: {})
      end

      let(:body) do
        '{
          "value": [
            {
              "id": "b320ee12-b1cd-4cca-b648-a437be61c5cd",
              "deletedDateTime": null,
              "classification": null,
              "createdDateTime": "2018-12-22T00:51:37Z",
              "creationOptions": [],
              "description": "Self help community for library",
              "displayName": "Library Assist",
              "groupTypes": [
                  "Unified"
              ],
              "mail": "library2@contoso.com",
              "mailEnabled": true,
              "mailNickname": "library"
            }
          ]
        }'
      end

      it do
        result = groups.get
        expect(result.size).to eq(1)
        expect(result.first)
          .to have_attributes(id: "b320ee12-b1cd-4cca-b648-a437be61c5cd", deleted_date_time: nil,
                              classification: nil, created_date_time: "2018-12-22T00:51:37Z",
                              creation_options: [], description: "Self help community for library",
                              display_name: "Library Assist", group_types: ["Unified"],
                              mail: "library2@contoso.com", mail_enabled: true, mail_nickname: "library")
      end
    end

    describe 'Get a filtered list of groups including the count of returned objects' do
      before do
        params = "$filter=hasMembersWithLicenseErrors%20eq%20true&$select=id,displayName"
        stub_request(:get, "https://graph.microsoft.com/v1.0/groups?$count=true&#{params}")
          .to_return(status: 200, body: body, headers: {})
      end

      let(:body) do
        <<~JSON
          {
            "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#groups(id,displayName)",
            "@odata.count":2,
            "value": [
              {
                "id": "11111111-2222-3333-4444-555555555555",
                "displayName": "Contoso Group 1"
              },
              {
                "id": "22222222-3333-4444-5555-666666666666",
                "displayName": "Contoso Group 2"
              }
            ]
          }
        JSON
      end

      it do
        result = groups.filter("hasMembersWithLicenseErrors eq true")
                       .select([:id, :display_name])
                       .get(count: true)
        expect(result.size).to eq(2)
        expect(result.odata_context).to eq("https://graph.microsoft.com/v1.0/$metadata#groups(id,displayName)")
        expect(result.odata_count).to eq(2)
        expect(result.first)
          .to have_attributes(id: "11111111-2222-3333-4444-555555555555", display_name: "Contoso Group 1")
      end
    end

    describe 'Get only a count of groups' do
      before do
        stub_request(:get, "https://graph.microsoft.com/v1.0/groups/$count")
          .to_return(status: 200, body: body, headers: {})
      end

      let(:body) do
        <<~JSON
          893
        JSON
      end

      it do
        result = groups.count
        expect(result).to eq(893)
      end
    end

    describe 'Use $filter and $top to get one group with a display name that starts
              with \'a\' including a count of returned objects' do
      before do
        params = "$count=true&$filter=startswith(displayName,%20'a')&$orderBy=displayName&$top=1"
        stub_request(:get, "https://graph.microsoft.com/v1.0/groups?#{params}")
          .to_return(status: 200, body: body, headers: {})
      end

      let(:body) do
        <<~JSON
          {
            "@odata.context":"https://graph.microsoft.com/v1.0/$metadata#groups",
            "@odata.count":1,
            "value":[
              {
                "displayName":"a",
                "mailNickname":"a241"
              }
            ]
          }
        JSON
      end

      it do
        result = groups.filter("startswith(displayName, 'a')")
                       .order_by('displayName')
                       .get(count: true, top: 1)
        expect(result.odata_context).to eq("https://graph.microsoft.com/v1.0/$metadata#groups")
        expect(result.odata_count).to eq(1)
        expect(result.first)
          .to have_attributes(mail_nickname: "a241", display_name: "a")
      end
    end

    describe 'Use $search to get groups with display names that contain the letters
              \'Video\' including a count of returned objects' do
      before do
        params = "$count=true&$search=%22displayName:Video%22"
        stub_request(:get, "https://graph.microsoft.com/v1.0/groups?#{params}")
          .to_return(status: 200, body: body, headers: {})
      end

      let(:body) do
        <<~JSON
          {
            "@odata.context":"https://graph.microsoft.com/v1.0/$metadata#groups",
            "@odata.nextLink":"https://graph.microsoft.com/v1.0/groups?$count=true&$search=%22displayName:Video%22&$skip=10&$skiptoken=X'40'",
            "@odata.count":1396,
            "value":[
              {
                "displayName":"SFA Videos",
                "mail":"SFAVideos@service.contoso.com",
                "mailNickname":"SFAVideos"
              }
            ]
          }
        JSON
      end

      it do
        result = groups.search("\"displayName:Video\"")
                       .get(count: true)
        expect(result.odata_context).to eq("https://graph.microsoft.com/v1.0/$metadata#groups")
        expect(result.odata_count).to eq(1396)
        expect(result.first)
          .to have_attributes(mail: "SFAVideos@service.contoso.com", mail_nickname: "SFAVideos", display_name: "SFA Videos")
      end

      it 'works with next query' do
        result = groups.search("\"displayName:Video\"")
                       .get(count: true)
        expect(result.next_get_query).to eq(search: '"displayName:Video"', count: "true", skip: "10", skiptoken: "X'40'")
        # can call next query
        stub_request(:get, "https://graph.microsoft.com/v1.0/groups?$count=true&$search=%22displayName:Video%22&$skip=10&$skiptoken=X'40'")
          .to_return(status: 200, body: "{}", headers: {})
        groups.get(**result.next_get_query)
      end
    end
  end
end

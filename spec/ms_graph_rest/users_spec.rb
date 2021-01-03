module MsGraphRest
  RSpec.describe Users do
    let(:client) { MsGraphRest.new_client(access_token: "123") }
    let(:users) { client.users }

    describe 'Get all users' do
      before do
        stub_request(:get, "https://graph.microsoft.com/v1.0/users")
          .to_return(status: 200, body: body, headers: {})
      end

      let(:body) do
        '{
          "value": [
            {
              "displayName":"contoso1",
              "mail":"\'contoso1@gmail.com",
              "mailNickname":"contoso1_gmail.com#EXT#",
              "otherMails":["contoso1@gmail.com"],
              "proxyAddresses":["SMTP:contoso1@gmail.com"],
              "userPrincipalName":"contoso1_gmail.com#EXT#@microsoft.onmicrosoft.com"
            }
          ]
        }'
      end

      it do
        result = users.get
        expect(result.size).to eq(1)
        expect(result.first)
          .to have_attributes(display_name: 'contoso1',
                              mail: "'contoso1@gmail.com",
                              mail_nickname: "contoso1_gmail.com#EXT#",
                              other_mails: ["contoso1@gmail.com"],
                              proxy_addresses: ["SMTP:contoso1@gmail.com"],
                              user_principal_name: "contoso1_gmail.com#EXT\#@microsoft.onmicrosoft.com")
      end
    end

    describe 'Get a user account using a sign-in name' do
      before do
        select = "displayName,id"
        filter = "identities/any(c:c/issuerAssignedId%20eq%20'j.smith@yahoo.com')"
        stub_request(:get, "https://graph.microsoft.com/v1.0/users?$filter=#{filter}&$select=#{select}")
          .to_return(status: 200, body: body, headers: {})
      end

      let(:body) do
        '{
          "value": [
            {
              "displayName": "John Smith"
            }
          ]
        }'
      end

      it do
        results = users
                  .filter("identities/any(c:c/issuerAssignedId eq 'j.smith@yahoo.com')")
                  .select("displayName,id")
                  .get
        expect(results.size).to eq(1)
        expect(results.first)
          .to have_attributes(display_name: 'John Smith')
      end
    end

    describe 'Get users including their last sign-in time' do
      before do
        stub_request(:get, "https://graph.microsoft.com/v1.0/users?$select=displayName,userPrincipalName,signInActivity")
          .to_return(status: 200, body: body, headers: {})
      end

      let(:body) do
        '{
        "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#users(displayName,userPrincipalName,signInActivity)",
        "value": [
          {
            "displayName": "Adele Vance",
            "userPrincipalName": "AdeleV@contoso.com",
            "signInActivity": {
              "lastSignInDateTime": "2017-09-04T15:35:02Z",
              "lastSignInRequestId": "c7df2760-2c81-4ef7-b578-5b5392b571df"
            }
          },
          {
            "displayName": "Alex Wilber",
            "userPrincipalName": "AlexW@contoso.com",
            "signInActivity": {
              "lastSignInDateTime": "2017-07-29T02:16:18Z",
              "lastSignInRequestId": "90d8b3f8-712e-4f7b-aa1e-62e7ae6cbe96"
            }
          }
        ]
      }'
      end

      it do
        results = users
                  .select("displayName,userPrincipalName,signInActivity")
                  .get
        expect(results.odata.context)
          .to eq("https://graph.microsoft.com/v1.0/$metadata#users(displayName,userPrincipalName,signInActivity)")
        expect(results.size).to eq(2)
        expect(results.first).to have_attributes(display_name: 'Adele Vance',
                                                 user_principal_name: 'AdeleV@contoso.com')
        expect(results.first.sign_in_activity).to have_attributes(last_sign_in_date_time: '2017-09-04T15:35:02Z',
                                                                  last_sign_in_request_id: 'c7df2760-2c81-4ef7-b578-5b5392b571df')
      end
    end

    describe 'List the last sign-in time of users with a specific display name' do
      before do
        stub_request(:get, "https://graph.microsoft.com/v1.0/users?$filter=startswith(displayName,'Eric'),&$select=displayName,signInActivity")
          .to_return(status: 200, body: body, headers: {})
      end

      let(:body) do
        '{
          "@odata.context": "https://graph.microsoft.com/v1.0/users?$filter=startswith(displayName,\'Eric\')&$select=displayName,signInActivity",
          "value": [
            {
              "displayName": "Eric Solomon",
              "signInActivity": {
                "lastSignInDateTime": "2017-09-04T15:35:02Z",
                "lastSignInRequestId": "c7df2760-2c81-4ef7-b578-5b5392b571df"
              }
            }
          ]
        }'
      end

      it do
        results = users
                  .filter('startswith(displayName,\'Eric\'),')
                  .select('displayName,signInActivity')
                  .get
        expect(results.size).to eq(1)
        first = results.first
        expect(first).to have_attributes(display_name: 'Eric Solomon')
        expect(first.sign_in_activity).to have_attributes(last_sign_in_date_time: '2017-09-04T15:35:02Z',
                                                          last_sign_in_request_id: 'c7df2760-2c81-4ef7-b578-5b5392b571df')
      end
    end

    describe 'List the last sign-in time of users in a specific time range' do
      before do
        stub_request(:get, "https://graph.microsoft.com/v1.0/users?$filter=signInActivity/lastSignInDateTime%20le%202019-06-01T00:00:00Z")
          .to_return(status: 200, body: body, headers: {})
      end

      let(:body) do
        '{
          "@odata.context": "https://graph.microsoft.com/v1.0/users?filter=signInActivity/lastSignInDateTime le 2019-06-01T00:00:00Z",
          "value": [
            {
              "displayName": "Adele Vance",
              "userPrincipalName": "AdeleV@contoso.com",
              "signInActivity": {
                "lastSignInDateTime": "2019-05-04T15:35:02Z",
                "lastSignInRequestId": "c7df2760-2c81-4ef7-b578-5b5392b571df"
              }
            },
            {
              "displayName": "Alex Wilber",
              "userPrincipalName": "AlexW@contoso.com",
              "signInActivity": {
                "lastSignInDateTime": "2019-04-29T02:16:18Z",
                "lastSignInRequestId": "90d8b3f8-712e-4f7b-aa1e-62e7ae6cbe96"
              }
            }
          ]
        }'
      end

      it do
        results = users
                  .filter('signInActivity/lastSignInDateTime le 2019-06-01T00:00:00Z')
                  .get
        expect(results.size).to eq(2)
        first = results.first
        expect(first).to have_attributes(display_name: 'Adele Vance',
                                         user_principal_name: 'AdeleV@contoso.com')
        expect(first.sign_in_activity).to have_attributes(last_sign_in_date_time: '2019-05-04T15:35:02Z',
                                                          last_sign_in_request_id: 'c7df2760-2c81-4ef7-b578-5b5392b571df')
      end
    end
  end
end

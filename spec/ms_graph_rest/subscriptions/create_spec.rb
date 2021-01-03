module MsGraphRest
  RSpec.describe 'Subscriptions' do
    let(:client) { MsGraphRest.new_client(access_token: "123") }
    let(:body) do
      '{
        "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#subscriptions/$entity",
        "id": "7f105c7d-2dc5-4530-97cd-4e7ae6534c07",
        "resource": "me/mailFolders(\'Inbox\')/messages",
        "applicationId": "24d3b144-21ae-4080-943f-7067b395b913",
        "changeType": "created",
        "clientState": "secretClientValue",
        "notificationUrl": "https://webhook.azurewebsites.net/api/send/myNotifyClient",
        "expirationDateTime": "2016-11-20T18:23:45.9356913Z",
        "creatorId": "8ee44408-0679-472c-bc2a-692812af3437",
        "latestSupportedTlsVersion": "v1_2"
      }
      '
    end
    let(:subscriptions) { client.subscriptions }

    before do
      stub_request(:post, "https://graph.microsoft.com/v1.0/subscriptions")
        .to_return(status: 201, body: body, headers: {})
    end

    it 'can be created' do
      result = subscriptions.create(
        change_type: "created",
        notification_url: "https://webhook.azurewebsites.net/api/send/myNotifyClient",
        resource: "me/mailFolders('Inbox')/messages",
        expiration_date_time: "2016-11-20T18:23:45.9356913Z",
        client_state: "secretClientValue"
      )

      expect(result).to have_attributes(
        "odata_context" => "https://graph.microsoft.com/v1.0/$metadata#subscriptions/$entity",
        "id": "7f105c7d-2dc5-4530-97cd-4e7ae6534c07",
        "resource": "me/mailFolders('Inbox')/messages",
        "application_id": "24d3b144-21ae-4080-943f-7067b395b913",
        "change_type": "created",
        "client_state": "secretClientValue",
        "notification_url": "https://webhook.azurewebsites.net/api/send/myNotifyClient",
        "expiration_date_time": "2016-11-20T18:23:45.9356913Z",
        "creator_id": "8ee44408-0679-472c-bc2a-692812af3437"
      )
    end
  end
end

module MsGraphRest
  RSpec.describe 'Subscriptions', "#update" do
    let(:client) { MsGraphRest.new_client(access_token: "123") }
    let(:body) do
      '{
        "id":"7f105c7d-2dc5-4530-97cd-4e7ae6534c07",
        "resource":"me/messages",
        "applicationId": "24d3b144-21ae-4080-943f-7067b395b913",
        "changeType":"created,updated",
        "clientState":"subscription-identifier",
        "notificationUrl":"https://webhook.azurewebsites.net/api/send/myNotifyClient",
        "lifecycleNotificationUrl":"https://webhook.azurewebsites.net/api/send/lifecycleNotifications",
        "expirationDateTime":"2016-11-22T18:23:45.9356913Z",
        "creatorId": "8ee44408-0679-472c-bc2a-692812af3437",
        "latestSupportedTlsVersion": "v1_2",
        "encryptionCertificate": "",
        "encryptionCertificateId": "",
        "includeResourceData": false
      }'
    end
    let(:subscriptions) { client.subscriptions }

    before do
      stub_request(:patch, "https://graph.microsoft.com/v1.0/subscriptions/7f105c7d-2dc5-4530-97cd-4e7ae6534c07")
        .to_return(status: 200, body: body, headers: {})
    end

    it 'can be updated' do
      result = client.subscriptions.update("7f105c7d-2dc5-4530-97cd-4e7ae6534c07",
                                           expiration_date_time: "2016-11-20T18:23:45.9356913Z")

      expect(result).to have_attributes(
        "id" => "7f105c7d-2dc5-4530-97cd-4e7ae6534c07",
        "resource" => "me/messages",
        "application_id" => "24d3b144-21ae-4080-943f-7067b395b913",
        "change_type" => "created,updated",
        "client_state" => "subscription-identifier",
        "notification_url" => "https://webhook.azurewebsites.net/api/send/myNotifyClient",
        "lifecycle_notification_url" => "https://webhook.azurewebsites.net/api/send/lifecycleNotifications",
        "expiration_date_time" => "2016-11-22T18:23:45.9356913Z",
        "creator_id" => "8ee44408-0679-472c-bc2a-692812af3437",
        "encryption_certificate" => "",
        "encryption_certificate_id" => "",
        "include_resource_data": false
      )
    end
  end
end

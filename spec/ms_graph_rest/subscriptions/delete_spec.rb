module MsGraphRest
  RSpec.describe 'Subscriptions', "#delete" do
    let(:client) { MsGraphRest.new_client(access_token: "123") }
    let(:subscriptions) { client.subscriptions }

    before do
      stub_request(:delete, "https://graph.microsoft.com/v1.0/subscriptions/7f105c7d-2dc5-4530-97cd-4e7ae6534c07")
        .to_return(status: 204, body: '', headers: {})
    end

    it 'can be deleted' do
      result = subscriptions.delete('7f105c7d-2dc5-4530-97cd-4e7ae6534c07')

      expect(result).to eq(true)
    end
  end
end

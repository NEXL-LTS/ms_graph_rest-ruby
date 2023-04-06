require 'spec_helper'

module MsGraphRest
  RSpec.describe 'Event' do
    let(:client) { MsGraphRest.new_client(access_token: "access_token") }
    let(:event_query) { client.event(path) }

    describe 'Get single message' do
      let(:path) { 'me' }
      let(:event_id) { 'event_id' }
      let(:body) { { 'itemId' => 'Item Id', 'iCalUid' => 'Calendar Uid' }.to_json }

      before do
        stub_request(:get, "https://graph.microsoft.com/v1.0/me/events/#{event_id}").to_return(status: 200, body: body, headers: {})
      end

      it do
        result = event_query.get(event_id)
        expect(result).to have_attributes(itemId: "Item Id", 'iCalUid' => 'Calendar Uid')
      end
    end

    describe 'Get instances of recurring message' do
      let(:path) { 'me' }
      let(:event_id) { 'event_id' }
      let(:start_date_time) { Time.parse('2023-04-05T10:04:58 UTC') }
      let(:end_date_time) { Time.parse('2023-05-31T10:04:58 UTC') }
      let(:body) { File.read("#{File.dirname(__FILE__)}/event/instances.json") }

      before do
        stub_request(:get, "https://graph.microsoft.com/v1.0/me/events/#{event_id}/instances?" \
                           "endDateTime=2023-05-31T10:04:58Z&startDateTime=2023-04-05T10:04:58Z")
          .to_return(status: 200, body: body, headers: {})
      end

      it do
        result = event_query.get_instances(event_id, start_date_time: start_date_time, end_date_time: end_date_time)
        expect(result.size).to eq(3)
        expect(result.first)
          .to have_attributes(i_cal_u_id: '040000008200E00074C5B7101A82E00807E705104AAEFBBC6F67D9010000000000000000100000005D70DF1FCF77AF439519B' \
                                          '6F639B957D9',
                              original_end_time_zone: 'South Africa Standard Time',
                              original_start_time_zone: 'South Africa Standard Time',
                              reminder_minutes_before_start: 15,
                              is_reminder_on: true)
        expect(result.first.response_status)
          .to have_attributes(response: 'organizer', time: '0001-01-01T00:00:00Z')
      end
    end
  end
end

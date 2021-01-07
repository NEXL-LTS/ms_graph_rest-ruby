require 'spec_helper'

module MsGraphRest
  RSpec.describe 'CalendarView' do
    let(:client) { MsGraphRest.new_client(access_token: "123") }
    let(:calendar_view) { client.calendar_view(path) }

    describe 'Get default calendar view' do
      let(:path) { 'me' }
      let(:body) do
        '{
          "value": [
            {
              "originalStartTimeZone": "originalStartTimeZone-value",
              "originalEndTimeZone": "originalEndTimeZone-value",
              "responseStatus": {
                "response": "",
                "time": "datetime-value"
              },
              "iCalUId": "iCalUId-value",
              "reminderMinutesBeforeStart": 99,
              "isReminderOn": true
            }
          ]
        }
        '
      end

      before do
        params = "endDateTime=2020-01-02T19:00:00-08:00&startDateTime=2020-01-01T19:00:00-08:00"
        stub_request(:get, "https://graph.microsoft.com/v1.0/me/calendarView?#{params}")
          .to_return(status: 200, body: body, headers: {})
      end

      it do
        result = calendar_view.get(start_date_time: '2020-01-01T19:00:00-08:00', end_date_time: '2020-01-02T19:00:00-08:00')
        expect(result.size).to eq(1)
        expect(result.first)
          .to have_attributes(original_start_time_zone: "originalStartTimeZone-value",
                              original_end_time_zone: "originalEndTimeZone-value",
                              i_cal_u_id: "iCalUId-value",
                              reminder_minutes_before_start: 99,
                              is_reminder_on: true)
        expect(result.first.response_status)
          .to have_attributes(response: "", time: "datetime-value")
      end
    end

    describe 'Get user calendar with select' do
      let(:body) do
        '{
          "@odata.context":"https://graph.microsoft.com/...",
          "value":[
              {
                  "@odata.etag":"W/\"ZlnW4RIAV06KYYwlrfNZvQAAKGWwbw==\"",
                  "id":"AAMkAGIAAAoZDOFAAA=",
                  "subject":"Orientation ",
                  "bodyPreview":"Dana, this is the time you selected for our orientation. Please bring the notes I sent you.",
                  "body":{
                      "contentType":"html",
                      "content":"<p>Example</p>"
                  },
                  "start":{
                      "dateTime":"2017-04-21T10:00:00.0000000",
                      "timeZone":"Pacific Standard Time"
                  },
                  "end":{
                      "dateTime":"2017-04-21T12:00:00.0000000",
                      "timeZone":"Pacific Standard Time"
                  },
                  "location": {
                      "displayName": "Assembly Hall",
                      "locationType": "default",
                      "uniqueId": "Assembly Hall",
                      "uniqueIdType": "private"
                  },
                  "locations": [
                      {
                          "displayName": "Assembly Hall",
                          "locationType": "default",
                          "uniqueIdType": "unknown"
                      }
                  ],
                  "attendees":[
                      {
                          "type":"required",
                          "status":{
                              "response":"none",
                              "time":"0001-01-01T00:00:00Z"
                          },
                          "emailAddress":{
                              "name":"Samantha Booth",
                              "address":"samanthab@a830edad905084922E17020313.onmicrosoft.com"
                          }
                      },
                      {
                          "type":"required",
                          "status":{
                              "response":"none",
                              "time":"0001-01-01T00:00:00Z"
                          },
                          "emailAddress":{
                              "name":"Dana Swope",
                              "address":"danas@a830edad905084922E17020313.onmicrosoft.com"
                          }
                      }
                  ],
                  "organizer":{
                      "emailAddress":{
                          "name":"Samantha Booth",
                          "address":"samanthab@a830edad905084922E17020313.onmicrosoft.com"
                      }
                  }
              }
          ]
      }
        '
      end
      let(:result) do
        client.calendar_view('users/123').select([:subject, :body, :body_preview, :organizer, :attendees, :start, :end, :location])
              .get(start_date_time: Time.parse('2020-01-01T19:00:00-08:00'),
                   end_date_time: Time.parse('2020-01-02T19:00:00-08:00'))
      end
      let(:event) { result.first }
      let(:attendee) { event.attendees.first }
      let(:organizer) { event.organizer }

      before do
        params = "endDateTime=2020-01-02T19:00:00-08:00&startDateTime=2020-01-01T19:00:00-08:00"
        select_param = "subject,body,bodyPreview,organizer,attendees,start,end,location"
        stub_request(:get, "https://graph.microsoft.com/v1.0/users/123/calendarView?$select=#{select_param}&#{params}")
          .to_return(status: 200, body: body, headers: {})
      end

      it 'returns correct result' do
        expect(result).to have_attributes(odata_context: "https://graph.microsoft.com/...", size: 1)
      end

      it 'returns correct event' do
        expect(event).to have_attributes(id: "AAMkAGIAAAoZDOFAAA=",
                                         odata_etag: "W/\"ZlnW4RIAV06KYYwlrfNZvQAAKGWwbw==\"",
                                         subject: "Orientation ",
                                         body_preview: "Dana, this is the time you selected for our orientation. Please bring the notes I sent you.")
        expect(event.body).to have_attributes(content_type: "html", content: "<p>Example</p>")
        expect(event.start).to have_attributes(date_time: "2017-04-21T10:00:00.0000000",
                                               time_zone: "Pacific Standard Time")
        expect(event.end).to have_attributes(date_time: "2017-04-21T12:00:00.0000000",
                                             time_zone: "Pacific Standard Time")
        expect(event.location).to have_attributes(display_name: "Assembly Hall",
                                                  location_type: "default",
                                                  unique_id: "Assembly Hall",
                                                  unique_id_type: "private")
      end

      it 'returns correct attendees' do
        expect(attendee).to have_attributes(type: "required")
        expect(attendee.status).to have_attributes(response: "none", time: "0001-01-01T00:00:00Z")
        expect(attendee.email_address).to have_attributes(name: "Samantha Booth", address: "samanthab@a830edad905084922E17020313.onmicrosoft.com")
        expect(organizer.email_address).to have_attributes(name: "Samantha Booth", address: "samanthab@a830edad905084922E17020313.onmicrosoft.com")
      end
    end
  end
end

require 'spec_helper'

module MsGraphRest
  RSpec.describe 'MessagesDelta' do
    let(:client) { MsGraphRest.new_client(access_token: "123") }
    let(:messages_delta) { client.messages_delta(path, folder) }

    def fixture(name)
      File.read("#{__dir__}/#{name}.json")
    end

    describe 'default query' do
      let(:result) { messages_delta.get }

      let(:path) { 'me' }
      let(:folder) { 'inbox' }

      let(:body) { fixture('default') }

      before do
        stub_request(:get, "https://graph.microsoft.com/v1.0/me/mailFolders/inbox/messages/delta")
          .to_return(status: 200, body: body, headers: {})
      end

      it do
        expect(result).to have_attributes(
          odata_context: 'https://graph.microsoft.com/v1.0/$metadata#Collection(message)',
          odata_next_link: 'https://graph.microsoft.com/v1.0/me/mailFolders/Inbox/messages/delta?$skiptoken=stest',
          next_get_query: { skiptoken: 'stest' },
          odata_delta_link: nil
        )
      end

      it do
        stub_request(:get, "https://graph.microsoft.com/v1.0/me/mailFolders/inbox/messages/delta?$skiptoken=stest")
          .to_return(status: 200, body: body, headers: {})

        client.messages_delta(path, folder).get(**result.next_get_query)
      end

      it { expect(result.value).to have_attributes(size: 2) }

      describe 'first message' do
        let(:first_message) { result.value.first }

        it do
          expect(first_message).to have_attributes(
            odata_type: '#microsoft.graph.message',
            odata_etag: 'etest',
            created_date_time: '2021-11-01T15:08:41Z',
            last_modified_date_time: '2021-11-01T15:08:43Z',
            change_key: 'ctest',
            categories: ['cat1'],
            received_date_time: "2021-11-01T15:08:42Z",
            sent_date_time: "2021-11-01T15:08:42Z",
            has_attachments: false,
            internet_message_id: "imitest",
            subject: "stest",
            body_preview: "bptest",
            importance: "normal",
            parent_folder_id: "pfitest",
            conversation_id: "citest",
            conversation_index: "citest",
            is_delivery_receipt_requested: false,
            is_read_receipt_requested: false,
          )
        end

        it do
          expect(first_message).to have_attributes(
            is_read: false,
            is_draft: false,
            web_link: "wltest",
            inference_classification: "focused",
            id: "itest",
          )
        end
      end

      describe 'first message body' do
        let(:first_body) { result.value.first.body }

        it do
          expect(first_body).to have_attributes(
            content_type: "html",
            content: "ctest",
          )
        end
      end

      describe 'first sender email_address' do
        let(:first_sender_email_address) { result.value.first.sender.email_address }

        it do
          expect(first_sender_email_address).to have_attributes(
            name: "nTest",
            address: "test@microsoft.com",
          )
        end
      end

      describe 'first from email_address' do
        let(:first_from_email_address) { result.value.first.from.email_address }

        it do
          expect(first_from_email_address).to have_attributes(
            name: "fenTest",
            address: "testa@microsoft.com",
          )
        end
      end

      describe 'first to Recipients' do
        let(:first_to_receipients) { result.value.first.to_recipients }

        it { expect(first_to_receipients).to have_attributes(size: 1) }

        it do
          expect(first_to_receipients.first.email_address).to have_attributes(
            name: "trenTest",
            address: "testb@onmicrosoft.com",
          )
        end
      end

      describe 'first cc Recipients' do
        let(:first_cc_receipients) { result.value.first.cc_recipients }

        it { expect(first_cc_receipients).to have_attributes(size: 0) }
      end

      describe 'first bcc Recipients' do
        let(:first_bcc_receipients) { result.value.first.bcc_recipients }

        it { expect(first_bcc_receipients).to have_attributes(size: 0) }
      end

      describe 'first flag' do
        let(:first_flag) { result.value.first.flag }

        it { expect(first_flag).to have_attributes(flag_status: "notFlagged") }
      end
    end

    describe 'with select on users outbox' do
      let(:result) do
        messages_delta.select([:sender, :to_recipients, :received_date_time, :created_date_time])
                      .received_after(Date.parse('2021-10-04'))
                      .order_by('receivedDateTime desc')
                      .get
      end

      let(:path) { 'users/p@example.com' }
      let(:folder) { 'outbox' }

      let(:body) { fixture('select_outbox') }

      before do
        params = "$filter=receivedDateTime%20gt%202021-10-04&$orderBy=receivedDateTime%20desc"
        params += "&$select=sender,toRecipients,receivedDateTime,createdDateTime"
        stub_request(:get, "https://graph.microsoft.com/v1.0/users/p@example.com/mailFolders/outbox/messages/delta?#{params}")
          .to_return(status: 200, body: body, headers: {})
      end

      it do
        expect(result).to have_attributes(
          odata_context: 'https://graph.microsoft.com/v1.0/$metadata#Collection(message)',
          odata_next_link: nil,
          next_get_query: nil,
          odata_delta_link: 'https://graph.microsoft.com/v1.0/users/p@example.com/mailFolders/outbox/messages/delta?$deltatoken=dtest',
          delta_query: { deltatoken: 'dtest' }
        )
      end

      it do
        stub_request(:get, "https://graph.microsoft.com/v1.0/users/p@example.com/mailFolders/outbox/messages/delta?$deltatoken=dtest")
          .to_return(status: 200, body: body, headers: {})

        client.messages_delta(path, folder).get(**result.delta_query)
      end
    end

    describe 'default with deleted message' do
      let(:result) { messages_delta.get }

      let(:path) { 'me' }
      let(:folder) { 'inbox' }

      let(:body) { fixture('deleted_message') }

      before do
        stub_request(:get, "https://graph.microsoft.com/v1.0/me/mailFolders/inbox/messages/delta")
          .to_return(status: 200, body: body, headers: {})
      end

      it do
        expect(result).to have_attributes(
          odata_context: 'https://graph.microsoft.com/v1.0/$metadata#Collection(message)',
          odata_next_link: 'https://graph.microsoft.com/v1.0/me/mailFolders/Inbox/messages/delta?$skiptoken=stest',
          next_get_query: { skiptoken: 'stest' },
          odata_delta_link: nil
        )
      end

      describe 'first message' do
        let(:first_message) { result.value.first }

        it do
          expect(first_message.removed).to have_attributes(reason: "changed")
        end
      end
    end
  end
end

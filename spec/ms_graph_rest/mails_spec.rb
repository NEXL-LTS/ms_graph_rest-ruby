require 'spec_helper'

module MsGraphRest
  RSpec.describe 'Mails' do
    subject { Mails.new(client: client).get('/user/user_id/messages/message_id') }

    let(:client) { double }

    describe "get" do
      before { allow(client).to receive(:get).and_return(response) }

      describe 'without sentDateTime' do
        let(:response) {
          {
            "id" => "message_id",
            "subject" => "Priorities + Roadmap for the Quarter",
            "sentDateTime" => nil,
            "conversationId" => "conversation_id",
            "webLink" => "https://outlook.office365.com/owa/?ItemID=itemId&exvsurl=1&viewmodel=ReadMessageItem",
            "sender" => { "emailAddress" => { "name" => "Konrad Konczak-Islam", "address" => "konrad@nexl.io" } },
            "from" => { "emailAddress" => { "name" => "Konrad Konczak-Islam", "address" => "konrad@nexl.io" } },
            "toRecipients" => [{ "emailAddress" => { "name" => "Philipp Thurner", "address" => "phil@nexl.com.au" } },
                               { "emailAddress" => { "name" => "Grant Petersen-Speelman", "address" => "grant@nexl.io" } },
                               { "emailAddress" => { "name" => "Bapu Sethi", "address" => "bapu@nexl.io" } }],
            "ccRecipients" => [],
            "bccRecipients" => [],
            "replyTo" => [],
            "internetMessageId" => "internet_message_id"
          }
        }

        it("message_id") {
          expect(subject.sent_at).to be_nil
        }
      end

      describe 'with sentDateTime' do
        let(:response) {
          {
            "id" => "message_id",
            "sentDateTime" => "2020-09-07T03:12:25Z",
            "subject" => "Priorities + Roadmap for the Quarter",
            "conversationId" => "conversation_id",
            "webLink" => "https://outlook.office365.com/owa/?ItemID=itemId&exvsurl=1&viewmodel=ReadMessageItem",
            "sender" => { "emailAddress" => { "name" => "Konrad Konczak-Islam", "address" => "konrad@nexl.io" } },
            "from" => { "emailAddress" => { "name" => "Konrad Konczak-Islam", "address" => "konrad@nexl.io" } },
            "toRecipients" => [{ "emailAddress" => { "name" => "Philipp Thurner", "address" => "phil@nexl.com.au" } },
                               { "emailAddress" => { "name" => "Grant Petersen-Speelman", "address" => "grant@nexl.io" } },
                               { "emailAddress" => { "name" => "Bapu Sethi", "address" => "bapu@nexl.io" } }],
            "ccRecipients" => [{ "emailAddress" => { "name" => "May", "address" => "may@nexl.io" } }],
            "bccRecipients" => [],
            "replyTo" => [],
            "internetMessageId" => "internet_message_id"
          }
        }

        it("message_id") {
          expect(subject.message_id).to eq("message_id")
        }

        it("conversation_id") {
          expect(subject.conversation_id).to eq("conversation_id")
        }

        it("sent_at") {
          expect(subject.sent_at).not_to be_nil
        }

        it("sender") {
          expect(subject.sender.email).to eq("konrad@nexl.io")
        }

        it("to_recipients") {
          expect(
            subject.to_recipients.map(&:email)
          ).to contain_exactly("phil@nexl.com.au", "grant@nexl.io", "bapu@nexl.io")
        }

        it("cc_recipients") {
          expect(
            subject.cc_recipients.map(&:email)
          ).to contain_exactly("may@nexl.io")
        }

        it("recipients") {
          expect(
            subject.recipients.map(&:email)
          ).to contain_exactly("phil@nexl.com.au", "grant@nexl.io", "bapu@nexl.io", "may@nexl.io")
        }

        it("payload") {
          expect(subject.payload).not_to be_nil
        }

        it("internet_message_id") {
          expect(subject.internet_message_id).to eq("internet_message_id")
        }
      end

      describe 'without toRecipients' do
        let(:response) {
          {
            "id" => "message_id",
            "subject" => "Priorities + Roadmap for the Quarter",
            "sentDateTime" => nil,
            "conversationId" => "conversation_id",
            "webLink" => "https://outlook.office365.com/owa/?ItemID=itemId&exvsurl=1&viewmodel=ReadMessageItem",
            "sender" => { "emailAddress" => { "name" => "Konrad Konczak-Islam", "address" => "konrad@nexl.io" } },
            "from" => { "emailAddress" => { "name" => "Konrad Konczak-Islam", "address" => "konrad@nexl.io" } },
            "toRecipients" => [{ "emailAddress" => { "name" => "Philipp Thurner", "address" => "phil@nexl.com.au" } }],
            "bccRecipients" => [],
            "replyTo" => [],
            "internetMessageId" => "internet_message_id"
          }
        }

        it { expect(subject.recipients).to eq([{ "email" => "phil@nexl.com.au", "name" => "Philipp Thurner" }]) }
      end

      describe 'without ccRecipients' do
        let(:response) {
          {
            "id" => "message_id",
            "subject" => "Priorities + Roadmap for the Quarter",
            "sentDateTime" => nil,
            "conversationId" => "conversation_id",
            "webLink" => "https://outlook.office365.com/owa/?ItemID=itemId&exvsurl=1&viewmodel=ReadMessageItem",
            "sender" => { "emailAddress" => { "name" => "Konrad Konczak-Islam", "address" => "konrad@nexl.io" } },
            "from" => { "emailAddress" => { "name" => "Konrad Konczak-Islam", "address" => "konrad@nexl.io" } },
            "ccRecipients" => [],
            "bccRecipients" => [],
            "replyTo" => [],
            "internetMessageId" => "internet_message_id"
          }
        }

        it { expect(subject.recipients).to eq([]) }
      end
    end

    describe "all" do
      subject { Mails.new(client: client) }

      let(:response) {
        {
          "id" => "message_id",
          "sentDateTime" => "2020-09-07T03:12:25Z",
          "subject" => "Priorities + Roadmap for the Quarter",
          "conversationId" => "conversation_id",
          "webLink" => "https://outlook.office365.com/owa/?ItemID=itemId&exvsurl=1&viewmodel=ReadMessageItem",
          "sender" => { "emailAddress" => { "name" => "Konrad Konczak-Islam", "address" => "konrad@nexl.io" } },
          "from" => { "emailAddress" => { "name" => "Konrad Konczak-Islam", "address" => "konrad@nexl.io" } },
          "toRecipients" => [{ "emailAddress" => { "name" => "Philipp Thurner", "address" => "phil@nexl.com.au" } },
                             { "emailAddress" => { "name" => "Grant Petersen-Speelman", "address" => "grant@nexl.io" } },
                             { "emailAddress" => { "name" => "Bapu Sethi", "address" => "bapu@nexl.io" } }],
          "ccRecipients" => [],
          "bccRecipients" => [],
          "replyTo" => [],
          "internetMessageId" => "internet_message_id"
        }
      }
      let(:paginated_response) { { "@odata.nextLink" => second_page, "value" => [response] } }
      let(:next_response) { { "value" => [response] } }
      let(:client) { double }
      let(:first_page) { "first_page" }
      let(:second_page) { "second_page" }

      before {
        allow(client).to receive(:get).with("me/messages", anything).and_return(paginated_response)
        allow(client).to receive(:get).with(second_page, anything).and_return(next_response)
      }

      it("fetches next link") {
        expect { |b| subject.all(Date.parse('2021-01-01'), &b) }.to yield_control.exactly(2).times
      }
    end
  end
end

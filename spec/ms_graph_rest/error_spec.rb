require 'spec_helper'

module MsGraphRest
  RSpec.describe Error do
    let(:error_message) { "Error message" }

    it "can be created" do
      expect(described_class.new(error_message).message).to eq(error_message)
    end

    describe "#wrap_request_error" do
      let(:faraday_error) { faraday_error_class.new StandardError.new, { body: body.to_json, status: status } }
      let(:status) { nil }
      let(:body) { {} }

      describe 'BadRequestError' do
        let(:body) { { "error" => { "code" => "AuthenticationError" } } }
        let(:faraday_error_class) { Faraday::BadRequestError }

        it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_kind_of(AuthenticationError) }
      end

      describe 'UserNotFound' do
        let(:body) { { "error" => { "code" => "AuthenticationError", "message" => "User not found" } } }
        let(:faraday_error_class) { Faraday::ResourceNotFound }

        it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_kind_of(UserNotFound) }
      end

      describe 'MailboxNotEnabledError' do
        let(:body) { { "error" => { "code" => "MailboxNotEnabledForRESTAPI" } } }
        let(:faraday_error_class) { Faraday::ResourceNotFound }

        it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_kind_of(MailboxNotEnabledError) }
      end

      describe 'ItemNotFoundError' do
        let(:body) { { "error" => { "code" => "ErrorItemNotFound" } } }
        let(:faraday_error_class) { Faraday::ResourceNotFound }

        it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_kind_of(ItemNotFoundError) }
      end

      describe 'ResourceNotFound' do
        let(:body) { { "error" => { "code" => "AuthenticationError" } } }
        let(:faraday_error_class) { Faraday::ResourceNotFound }

        it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_kind_of(ResourceNotFound) }
      end

      describe 'UnauthorizedError' do
        let(:body) { { "error" => { "code" => "AuthenticationError" } } }
        let(:faraday_error_class) { Faraday::UnauthorizedError }

        it { expect(MsGraphRest.wrap_request_error(faraday_error)).to eq(faraday_error) }
      end

      describe 'InvalidAuthenticationTokenError' do
        let(:body) { { "error" => { "code" => "InvalidAuthenticationToken" } } }
        let(:faraday_error_class) { Faraday::UnauthorizedError }

        it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_kind_of(InvalidAuthenticationTokenError) }
      end

      describe 'ClientError' do
        let(:faraday_error_class) { Faraday::ClientError }

        context 'when Application is over its MailboxConcurrency limit.' do
          let(:body) { { "error" => { "code" => "ApplicationThrottled", "message" => "Application is over its MailboxConcurrency limit." } } }

          it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_kind_of(MailboxConcurrencyLimitError) }
        end

        context 'when other error' do
          let(:body) { { "error" => { "code" => "OtherError" } } }

          it { expect(MsGraphRest.wrap_request_error(faraday_error)).to eq(faraday_error) }
        end
      end

      describe 'ServerError' do
        let(:faraday_error_class) { Faraday::ServerError }

        context 'when Unable to resolve User Id' do
          let(:body) { { "error" => { "code" => "InternalServerError", "message" => "Unable to resolve User Id" } } }

          it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_kind_of(UnableToResolveUserId) }
        end

        context 'when Resource Unhealthy' do
          let(:body) { { "error" => { "code" => "ResourceUnhealthy", "message" => "SystemMemoryProtectionUtilizationMonitor is unhealthy." } } }

          it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_kind_of(ResourceUnhealthyError) }
        end

        context 'when not Unable to resolve User Id' do
          let(:body) { { "error" => { "code" => "InternalServerError" } } }

          it { expect(MsGraphRest.wrap_request_error(faraday_error)).to eq(faraday_error) }
        end

        context 'when Mailbox Store Unavailable' do
          let(:body) { { "error" => { "code" => "ErrorMailboxStoreUnavailable", "message" => "The mailbox database is temporarily unavailable." } } }

          it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_kind_of(MailboxStoreUnavailableError) }
        end

        context 'when status 503' do
          let(:status) { 503 }

          it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_kind_of(ServiceUnavailableError) }
        end

        context 'when non json body' do
          let(:faraday_error) { faraday_error_class.new StandardError.new, "<html>body</html>" }
          let(:faraday_error_class) { Faraday::TimeoutError }

          it { expect(MsGraphRest.wrap_request_error(faraday_error)).to eq(faraday_error) }
        end

        context 'when invalid json body' do
          let(:faraday_error) { faraday_error_class.new StandardError.new, { body: "{ invalid | body }" } }
          let(:faraday_error_class) { Faraday::TimeoutError }

          it { expect(MsGraphRest.wrap_request_error(faraday_error)).to eq(faraday_error) }
        end
      end

      describe 'Faraday::TimeoutError' do
        let(:faraday_error) { faraday_error_class.new StandardError.new, nil }
        let(:faraday_error_class) { Faraday::TimeoutError }

        it { expect(MsGraphRest.wrap_request_error(faraday_error)).to eq(faraday_error) }
      end
    end
  end
end

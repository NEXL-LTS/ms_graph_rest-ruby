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
        let(:faraday_error_class) { Faraday::BadRequestError }

        describe 'AuthenticationError' do
          let(:body) { { "error" => { "code" => "AuthenticationError" } } }

          it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_a(AuthenticationError) }
        end

        describe 'InvalidGrantError' do
          let(:body) { { "error" => "invalid_grant" } }

          it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_a(InvalidGrantError) }
        end

        describe "NamedPropertyNotFoundError" do
          let(:body) do
            {
              "error" => {
                "code" => "RequestBroker-ParseUri",
                "message" =>
                  "Could not find a property named 'Flag' on type 'Microsoft.OutlookServices.Message'"
              }
            }
          end

          it do
            expect(MsGraphRest.wrap_request_error(faraday_error)).to be_a(
              NamedPropertyNotFoundError
            )
          end
        end

        describe "InvalidFilterClauseError" do
          let(:body) do
            {
              "error" => {
                "code" => "BadRequest",
                "message" =>
                  "Invalid filter clause: ')' or ',' expected at position 41 in 'emailAddresses/any(a:a/address eq 'mia.o'connor@minterellison.com')'"
              }
            }
          end

          it do
            expect(MsGraphRest.wrap_request_error(faraday_error)).to be_a(
              InvalidFilterClauseError
            )
          end
        end
      end

      describe 'UserNotFound' do
        let(:body) { { "error" => { "code" => "AuthenticationError", "message" => "User not found" } } }
        let(:faraday_error_class) { Faraday::ResourceNotFound }

        it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_a(UserNotFound) }
      end

      describe 'MailboxNotEnabledError' do
        let(:body) { { "error" => { "code" => "MailboxNotEnabledForRESTAPI" } } }
        let(:faraday_error_class) { Faraday::ResourceNotFound }

        it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_a(MailboxNotEnabledError) }
      end

      describe 'ItemNotFoundError' do
        let(:body) { { "error" => { "code" => "ErrorItemNotFound" } } }
        let(:faraday_error_class) { Faraday::ResourceNotFound }

        it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_a(ItemNotFoundError) }
      end

      describe 'ResourceNotDiscovered' do
        let(:body) { { "error" => { "code" => "ResourceNotFound", "message" => "Resource could not be discovered." } } }
        let(:faraday_error_class) { Faraday::ResourceNotFound }

        it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_a(ResourceNotDiscovered) }
      end

      describe 'ResourceNotFound' do
        let(:body) { { "error" => { "code" => "ResourceNotFound" } } }
        let(:faraday_error_class) { Faraday::ResourceNotFound }

        it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_a(ResourceNotFound) }
      end

      describe 'UnauthorizedError' do
        let(:body) { { "error" => { "code" => "AuthenticationError" } } }
        let(:faraday_error_class) { Faraday::UnauthorizedError }

        it { expect(MsGraphRest.wrap_request_error(faraday_error)).to eq(faraday_error) }
      end

      describe 'InvalidAuthenticationTokenError' do
        let(:body) { { "error" => { "code" => "InvalidAuthenticationToken" } } }
        let(:faraday_error_class) { Faraday::UnauthorizedError }

        it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_a(InvalidAuthenticationTokenError) }
      end

      describe 'ClientError' do
        let(:faraday_error_class) { Faraday::ClientError }

        context 'when Application is over its MailboxConcurrency limit.' do
          let(:body) { { "error" => { "code" => "ApplicationThrottled", "message" => "Application is over its MailboxConcurrency limit." } } }

          it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_a(MailboxConcurrencyLimitError) }
        end

        context 'when Application is over Request Limit' do
          let(:body) { { "error" => { "code" => "ApplicationThrottled", "message" => "Application is over its Request limit." } } }

          it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_a(ApplicationOverRequestLimitError) }
        end

        context 'when forbidden error' do
          let(:faraday_error_class) { Faraday::ForbiddenError }

          let(:body) { nil }
          let(:status) { '403' }

          it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_a(ForbiddenError) }
        end

        context 'when request timeout error' do
          let(:body) { {} }
          let(:status) { '408' }

          it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_a(RequestTimeoutError) }
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

          it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_a(UnableToResolveUserId) }
        end

        context 'when Resource Unhealthy' do
          let(:body) { { "error" => { "code" => "ResourceUnhealthy", "message" => "SystemMemoryProtectionUtilizationMonitor is unhealthy." } } }

          it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_a(ResourceUnhealthyError) }
        end

        context 'when not Unable to resolve User Id' do
          let(:body) { { "error" => { "code" => "InternalServerError" } } }

          it { expect(MsGraphRest.wrap_request_error(faraday_error)).to eq(faraday_error) }
        end

        context 'when Mailbox Store Unavailable' do
          let(:body) { { "error" => { "code" => "ErrorMailboxStoreUnavailable", "message" => "The mailbox database is temporarily unavailable." } } }

          it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_a(MailboxStoreUnavailableError) }
        end

        context 'when ErrorContentConversionFailed' do
          let(:body) { { "error" => { "code" => "ErrorContentConversionFailed", "message" => "Content conversion failed." } } }

          it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_a(ErrorContentConversionFailed) }
        end

        context 'when status 503' do
          let(:status) { 503 }

          it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_a(ServiceUnavailableError) }
        end

        context 'when status 504' do
          let(:status) { 504 }

          it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_a(BadGatewayError) }
        end

        context 'when unknown error' do
          let(:body) { { "error" => { "code" => "UnknownError", "message" => "T" } } }

          it { expect(MsGraphRest.wrap_request_error(faraday_error)).to be_a(UnknownServerError) }
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

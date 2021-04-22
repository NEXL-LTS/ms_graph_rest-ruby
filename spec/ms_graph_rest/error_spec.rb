require 'spec_helper'

module MsGraphRest
  RSpec.describe Error do
    let(:error_message) { "Error message" }

    it "can be created" do
      expect(described_class.new(error_message).message).to eq(error_message)
    end

    describe 'BadRequestErrorCreator' do
      let(:faraday_bad_request_error) {
        Faraday::BadRequestError.new StandardError.new, { body: { "error" => { "code" => "AuthenticationError" } }.to_json }
      }

      it "can be created" do
        expect(BadRequestErrorCreator.error(faraday_bad_request_error)).to be_kind_of(AuthenticationError)
      end
    end
  end
end

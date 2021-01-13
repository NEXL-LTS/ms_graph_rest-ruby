require 'spec_helper'

module MsGraphRest
  RSpec.describe Error do
    let(:error_message) { "Error message" }

    it "can be created" do
      expect(described_class.new(error_message).message).to eq(error_message)
    end
  end
end

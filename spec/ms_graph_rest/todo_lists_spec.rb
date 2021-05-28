require 'spec_helper'

module MsGraphRest
  RSpec.describe 'TodoLists' do
    let(:client) { MsGraphRest.new_client(access_token: "123") }
    let(:todo_lists) { client.todo_lists }
    let(:graph_url) { 'https://graph.microsoft.com/v1.0/' }

    describe 'Get todo lists' do
      let(:path) { 'me' }
      let(:body) { File.read("#{__dir__}/todo_lists.json") }
      let(:result) { todo_lists.get }

      before do
        params = ""
        stub_request(:get, "#{graph_url}me/todo/lists?#{params}")
          .to_return(status: 200, body: body, headers: {})
      end

      it { expect(result.size).to eq(2) }
      it { expect(result.first).to have_attributes(id: "AAMkADIyAAAAABrJAAA=", displayName: "Tasks") }
    end
  end
end

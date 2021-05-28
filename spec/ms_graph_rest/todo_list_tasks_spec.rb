require 'spec_helper'

module MsGraphRest
  RSpec.describe 'TodoListTasks' do
    let(:client) { MsGraphRest.new_client(access_token: "123") }
    let(:graph_url) { 'https://graph.microsoft.com/v1.0/' }

    describe 'Get todo tasks' do
      let(:path) { 'me' }
      let(:todo_list) { 'AAMkADVmODRlNDI1LTRhZjItNGE3NC04OTc3LTQ2YzEzZTkxMTBjYwAuAAAAAABVdkm94BatRrmJb_BaPvf5AQAbeJ9DMbI7TJH_l_vpv2_3AAAAAAESAAA%3D' }
      let(:body) { File.read("#{__dir__}/todo_list_tasks.json") }
      let(:result) { client.todo_list_tasks(todo_list).get }

      before do
        params = ""
        stub_request(:get, "#{graph_url}me/todo/lists/#{todo_list}/tasks?#{params}")
          .to_return(status: 200, body: body, headers: {})
      end

      it { expect(result.size).to eq(4) }
      it { expect(result.first).to have_attributes(title: "Duis ultrices nibh non eros fermentum sodales") }
    end
  end
end

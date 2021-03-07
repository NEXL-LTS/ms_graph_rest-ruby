require 'spec_helper'

module MsGraphRest
  RSpec.describe 'PlannerTasks' do
    let(:client) { MsGraphRest.new_client(access_token: "123") }
    let(:planner_tasks) { client.planner_tasks(path) }
    let(:graph_url) { 'https://graph.microsoft.com/v1.0/' }

    describe 'Get planner tasks' do
      let(:path) { 'me/planner/tasks' }
      let(:body) { File.read("#{__dir__}/../fixtures/planner_tasks_default.json") }
      let(:result) do
        planner_tasks.get
      end

      before do
        params = ""
        stub_request(:get, "#{graph_url}#{path}?#{params}")
          .to_return(status: 200, body: body, headers: {})
      end

      it { expect(result.size).to eq(23) }
      it { expect(result.first).to have_attributes(id: "102sl-tTCkyFHptTaFW5lGUACsAe", title: "Northwind HR Training Video Part I") }
      it { expect(result.next_get_query).to be_nil }

    end

    describe 'Get planner tasks with select' do

      let(:path) { 'me/planner/tasks' }
      let(:result) do
        client.planner_tasks.select([:id, :title, :dueDateTime]).get
      end
      let(:task) { result.first }
      let(:body) do
        '{
          "@odata.context": "https://graph.microsoft.com/v1.0/$metadata#Collection(microsoft.graph.plannerTask)",
          "@odata.count": 2,
          "value": [
              {
                  "@odata.etag": "W/\"JzEtVGFzayAgQEBAQEBAQEBAQEBAQEBAaCc=\"",
                  "id": "102sl-tTCkyFHptTaFW5lGUACsAe",
                  "title": "Northwind HR Training Video Part I",
                  "dueDateTime": "2018-09-03T00:00:00Z"
              },
              {
                  "@odata.etag": "W/\"JzEtVGFzayAgQEBAQEBAQEBAQEBAQEBAZCc=\"",
                  "id": "7aZeJUYK90OZiFq6H7Ug3mUACcdr",
                  "title": "Search Optimization",
                  "dueDateTime": "2018-08-29T00:00:00Z"
              }
          ]
        }'
      end

      before do
        select_param = 'id,title,dueDateTime'
        stub_request(:get, "#{graph_url}#{path}?$select=#{select_param}")
          .to_return(status: 200, body: body, headers: {})
      end

      it 'returns correct result' do
        expect(result).to have_attributes(odata_context: "https://graph.microsoft.com/v1.0/$metadata#Collection(microsoft.graph.plannerTask)", size: 2)
      end

      it 'return correct first tasks' do
        expect(task).to have_attributes(id: '102sl-tTCkyFHptTaFW5lGUACsAe')
      end
    end

  end
end

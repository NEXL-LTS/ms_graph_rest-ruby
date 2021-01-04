require 'spec_helper'

module MsGraphRest
  RSpec.describe 'Mails' do
   subject {  Mails.new(client: client).get('id') }
   
   let(:client) { double }

   let(:response){
     {
      "id"=>"message_id",
      "sentDateTime"=>"2020-09-07T03:12:25Z",
      "subject"=>"Priorities + Roadmap for the Quarter",
      "conversationId"=>"conversation_id",
      "webLink"=>"https://outlook.office365.com/owa/?ItemID=itemId&exvsurl=1&viewmodel=ReadMessageItem",
      "sender"=>{"emailAddress"=>{"name"=>"Konrad Konczak-Islam", "address"=>"konrad@nexl.io"}},
      "from"=>{"emailAddress"=>{"name"=>"Konrad Konczak-Islam", "address"=>"konrad@nexl.io"}},
      "toRecipients"=>[{"emailAddress"=>{"name"=>"Philipp Thurner", "address"=>"phil@nexl.com.au"}},
                       {"emailAddress"=>{"name"=>"Grant Petersen-Speelman", "address"=>"grant@nexl.io"}},
                       {"emailAddress"=>{"name"=>"Bapu Sethi", "address"=>"bapu@nexl.io"}}],
      "ccRecipients"=>[],
      "bccRecipients"=>[],
      "replyTo"=>[]
    }
   }

   before{ allow(client).to receive(:get).and_return(response) }
   
   it("message_id"){
    expect(subject.message_id).to eq("message_id")
   }

   it("conversation_id"){
    expect(subject.conversation_id).to eq("conversation_id")
   }

   it("created"){
    expect(subject.created).not_to be_nil
   }

   it("sender"){
    expect(subject.sender.email).to eq("konrad@nexl.io")
   }

   it("recipients"){
    expect(
      subject.recipients.map(&:email)
    ).to contain_exactly("phil@nexl.com.au", "grant@nexl.io", "bapu@nexl.io")
   }
  end
end

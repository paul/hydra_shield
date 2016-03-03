require "spec_helper"

require "support/mock_controller"

require "json"

RSpec.describe "comparing with the actual hydra demo" do

  let(:controller) { MockController.new("test.example") }

  class UserShield < HydraShield::ResourceShield

    self.id          = -> { user_path(user) }
    self.type        = "User"
    self.label       = "User"
    self.description = "A User represents a person registered in the system."

    operation :user_replace,
              method: "PUT",
              description: "Replaces an existing User entity",
              expects: type, returns: type,
              status_codes: { 404 => "If the User entity wasn't found" }



  end

  describe "the generated vocab" do
    let(:example_vocab) { JSON.load(File.read("./spec/api-demo-vocab.json")) }
    let(:generated_vocab) { HydraShield::VocabShield.new(controller, HydraShield::Vocab.new(HydraShield.registered_shields)).attributes }

    it "should match the example app vocab" do
      File.write("./spec/generated-vocab.ugly.json", generated_vocab.to_json)
      `jq . ./spec/generated-vocab.ugly.json > ./spec/generated-vocab.json`
    end

  end

end

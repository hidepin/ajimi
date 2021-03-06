require 'spec_helper'

describe "Ajimi::Client" do
  let(:client) { Ajimi::Client.new }
  let(:config) { {
    source: (Ajimi::Server.new("source_host_value")),
    target: (Ajimi::Server.new("target_host_value")),
    check_root_path: "check_root_path_value",
    ignored_paths: ["/path_to_ignored1", "/path_to_ignored2"],
    ignored_contents: ({"/path_to_content" => /ignored_pattern/})
  } }
  let(:checker) { Ajimi::Checker.new(config) }
  let(:reporter) { Ajimi::Reporter.new(checker) }

  before do
    client.checker = checker
    client.reporter = reporter
  end

  describe "#check" do
    context "when checker returns true" do
      it "returns true" do
        expect(checker).to receive(:check).and_return(true)
        expect(reporter).to receive(:report)
        expect(client.check).to be true
      end
    end

    context "when checker returns false" do
      it "returns false" do
        expect(checker).to receive(:check).and_return(false)
        expect(reporter).to receive(:report)
        expect(client.check).to be false
      end
    end
    
  end
end

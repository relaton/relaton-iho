require "relaton/iho/processor"

describe Relaton::Iho::Processor do
  subject(:processor) { described_class.new }

  describe "#initialize" do
    it "sets short" do
      expect(processor.short).to eq :relaton_iho
    end

    it "sets prefix" do
      expect(processor.prefix).to eq "IHO"
    end

    it "sets defaultprefix" do
      expect(processor.defaultprefix).to eq %r{^IHO\s}
    end

    it "sets idtype" do
      expect(processor.idtype).to eq "IHO"
    end
  end

  describe "#get" do
    it "delegates to Bibliography.get" do
      expect(Relaton::Iho::Bibliography).to receive(:get).with("IHO B-11", "2020", {})
      processor.get("IHO B-11", "2020", {})
    end
  end

  describe "#from_xml" do
    it "delegates to Item.from_xml" do
      xml = "<bibdata/>"
      expect(Relaton::Iho::Item).to receive(:from_xml).with(xml)
      processor.from_xml(xml)
    end
  end

  describe "#from_yaml" do
    it "delegates to Item.from_yaml" do
      yaml = "---\ntitle: Test"
      expect(Relaton::Iho::Item).to receive(:from_yaml).with(yaml)
      processor.from_yaml(yaml)
    end
  end

  describe "#grammar_hash" do
    it "returns a grammar hash string" do
      expect(processor.grammar_hash).to be_instance_of String
      expect(processor.grammar_hash.size).to eq 32
    end

    it "memoizes the result" do
      expect(Relaton::Iho).to receive(:grammar_hash).once.and_return("abc123")
      processor.grammar_hash
      expect(processor.grammar_hash).to eq "abc123"
    end
  end

  describe "#remove_index_file" do
    it "removes the index file" do
      index = double("index")
      expect(Relaton::Index).to receive(:find_or_create).with(
        :iho, url: true, file: "#{Relaton::Iho::INDEXFILE}.yaml"
      ).and_return(index)
      expect(index).to receive(:remove_file)
      processor.remove_index_file
    end
  end
end

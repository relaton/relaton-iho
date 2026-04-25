require "relaton/iho/hash_parser_v1"

describe Relaton::Iho::HashParserV1 do
  let(:output_file) { "spec/fixtures/item_from_v1.yaml" }
  let(:input_hash) { YAML.load_file "spec/fixtures/item_v1.yaml" }
  let(:bib_hash) { described_class.hash_to_bib input_hash }
  let(:item) { Relaton::Iho::ItemData.new(**bib_hash) }
  let(:output_yaml) { Relaton::Iho::Item.to_yaml item }
  let(:output_hash) { YAML.safe_load output_yaml }

  it "parses hash to bib item" do
    File.write output_file, output_yaml, encoding: "UTF-8" unless File.exist? output_file
    expect(output_hash).to eq YAML.load_file(output_file)
  end

  describe "#series_hash_to_bib" do
    it "expands v1 array content into multiple titles" do
      hash = { series: [{ type: "main", title: {
        type: "original",
        content: [
          { content: "Bathymetric Publications", language: "en", script: "Latn" },
          { content: "Publications bathymétriques", language: "fr", script: "Latn" },
        ],
      } }] }
      result = described_class.hash_to_bib(hash)
      titles = result[:series].first.title
      expect(titles.size).to eq 2
      expect(titles[0].content).to eq "Bathymetric Publications"
      expect(titles[0].language).to eq "en"
      expect(titles[0].type).to eq "original"
      expect(titles[1].content).to eq "Publications bathymétriques"
      expect(titles[1].language).to eq "fr"
    end

    it "passes through simple string title unchanged" do
      hash = { series: [{ type: "main", title: "Some Series" }] }
      result = described_class.hash_to_bib(hash)
      titles = result[:series].first.title
      expect(titles.size).to eq 1
      expect(titles[0].content).to eq "Some Series"
    end
  end

  describe "#structuredidentifier_hash_to_bib" do
    it "wraps ext.structuredidentifier hash into Iho::StructuredIdentifier" do
      hash = { ext: { structuredidentifier: { docnumber: "S-100", part: "1" } } }
      result = described_class.hash_to_bib(hash)
      sid = result[:ext].structuredidentifier
      expect(sid).to all(be_a(Relaton::Iho::StructuredIdentifier))
      expect(sid.first.docnumber).to eq "S-100"
      expect(sid.first.part).to eq "1"
    end

    it "accepts structuredidentifier at top level" do
      hash = { structuredidentifier: { docnumber: "S-4", part: "B" } }
      result = described_class.hash_to_bib(hash)
      sid = result[:ext].structuredidentifier.first
      expect(sid.docnumber).to eq "S-4"
      expect(sid.part).to eq "B"
    end

    it "accepts an array of structuredidentifiers" do
      hash = { ext: { structuredidentifier: [
        { docnumber: "S-100", part: "1" },
        { docnumber: "S-100", part: "2" },
      ] } }
      result = described_class.hash_to_bib(hash)
      sid = result[:ext].structuredidentifier
      expect(sid.map(&:part)).to eq ["1", "2"]
    end
  end
end

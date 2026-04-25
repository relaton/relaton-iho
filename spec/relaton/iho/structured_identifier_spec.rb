describe Relaton::Iho::StructuredIdentifier do
  let(:sid) do
    described_class.new(
      docnumber: "S-100",
      part: "1",
      annexid: "A",
      appendixid: "1",
      supplementid: "1",
    )
  end

  it "exposes IHO-specific fields" do
    expect(sid.docnumber).to eq "S-100"
    expect(sid.part).to eq "1"
    expect(sid.annexid).to eq "A"
    expect(sid.appendixid).to eq "1"
    expect(sid.supplementid).to eq "1"
  end

  it "serialises to IHO-shaped XML" do
    xml = described_class.to_xml(sid)
    expect(xml).to include "<structuredidentifier>"
    expect(xml).to include "<docnumber>S-100</docnumber>"
    expect(xml).to include "<part>1</part>"
    expect(xml).to include "<annexid>A</annexid>"
    expect(xml).to include "<appendixid>1</appendixid>"
    expect(xml).to include "<supplementid>1</supplementid>"
    expect(xml).not_to include "partnumber"
    expect(xml).not_to include "supplementnumber"
  end

  it "round-trips through XML" do
    xml = described_class.to_xml(sid)
    parsed = described_class.from_xml(xml)
    expect(parsed.docnumber).to eq "S-100"
    expect(parsed.part).to eq "1"
    expect(parsed.annexid).to eq "A"
    expect(parsed.appendixid).to eq "1"
    expect(parsed.supplementid).to eq "1"
  end

  it "omits unset fields from XML" do
    minimal = described_class.new(docnumber: "S-4", part: "2")
    xml = described_class.to_xml(minimal)
    expect(xml).to include "<part>2</part>"
    expect(xml).not_to include "annexid"
    expect(xml).not_to include "appendixid"
    expect(xml).not_to include "supplementid"
  end

  describe "inside Relaton::Iho::Ext" do
    let(:ext) do
      Relaton::Iho::Ext.new(
        doctype: Relaton::Iho::Doctype.new(content: "standard"),
        structuredidentifier: [
          described_class.new(docnumber: "S-100", part: "1"),
        ],
      )
    end

    it "replaces the inherited Bib::StructuredIdentifier" do
      sid = ext.structuredidentifier.first
      expect(sid).to be_a described_class
      expect(sid).not_to be_a Relaton::Bib::StructuredIdentifier
    end

    it "serialises the IHO structuredidentifier inside <ext>" do
      xml = Relaton::Iho::Ext.to_xml(ext)
      expect(xml).to include "<structuredidentifier>"
      expect(xml).to include "<docnumber>S-100</docnumber>"
      expect(xml).to include "<part>1</part>"
    end

    it "round-trips through Ext XML" do
      xml = Relaton::Iho::Ext.to_xml(ext)
      parsed = Relaton::Iho::Ext.from_xml(xml)
      sid = parsed.structuredidentifier.first
      expect(sid).to be_a described_class
      expect(sid.docnumber).to eq "S-100"
      expect(sid.part).to eq "1"
    end
  end

  describe "Bibdata fixture with structuredidentifier" do
    let(:file) { "spec/fixtures/iho_part.xml" }
    let(:input_xml) { File.read file, encoding: "UTF-8" }
    let(:bib) { Relaton::Iho::Bibdata.from_xml input_xml }

    it "parses the IHO structuredidentifier" do
      sid = bib.ext.structuredidentifier.first
      expect(sid).to be_a described_class
      expect(sid.docnumber).to eq "S-100"
      expect(sid.part).to eq "1"
    end

    it "round-trips and validates against the IHO RNG" do
      expect(Relaton::Iho::Bibdata.to_xml(bib)).to be_equivalent_to input_xml
      schema = Jing.new("grammars/relaton-iho-compile.rng")
      expect(schema.validate(file)).to eq []
    end
  end
end

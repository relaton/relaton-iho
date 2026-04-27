RSpec.describe Relaton::Iho do
  it "has a version number" do
    expect(Relaton::Iho::VERSION).not_to be nil
  end

  it "retur grammar hash" do
    hash = Relaton::Iho.grammar_hash
    expect(hash).to be_instance_of String
    expect(hash.size).to eq 32
  end

  it "search a code", vcr: "b_11" do
    result = Relaton::Iho::Bibliography.search "IHO B-11"
    expect(result).to be_instance_of Relaton::Iho::ItemData
  end

  context "get document" do
    it "by code", vcr: "b_11" do
      expect do
        file = "spec/fixtures/b_11.xml"
        result = Relaton::Iho::Bibliography.get "IHO B-11"
        xml = result.to_xml bibdata: true
        File.write file, xml, encoding: "UTF-8" unless File.exist? file
        expect(xml).to be_equivalent_to File.read(file, encoding: "UTF-8")
          .sub(/(?<=<fetched>).*(?=<\/fetched>)/, Date.today.to_s)
        schema = Jing.new "grammars/relaton-iho-compile.rng"
        errors = schema.validate file
        expect(errors).to eq []
      end.to output(
        /\[relaton-iho\] INFO: \(IHO B-11\) Fetching from Relaton repository \.\.\./
      ).to_stderr_from_any_process
    end

    it "by code", vcr: "iho_s63" do
      result = Relaton::Iho::Bibliography.get "IHO S-63"
      expect(result.docidentifier.first.content).to eq "S-63"
    end

    it "raises on unparseable reference" do
      expect { Relaton::Iho::Bibliography.get "IHO S63" }
        .to raise_error(Pubid::Core::Errors::ParseError)
    end

    it "by code and edition", vcr: { cassette_name: "code_and_edition" } do
      result = Relaton::Iho::Bibliography.get "IHO B-6 4.2.0"
      expect(result.docidentifier.first.content).to eq "B-6"
      expect(result.edition.content).to eq "4.2.0"
    end

    it "take doc with shorter code", vcr: "s_4" do
      result = Relaton::Iho::Bibliography.get "IHO S-4"
      expect(result.docidentifier.first.content).to eq "S-4"
    end

    it "not found", vcr: { cassette_name: "not_found" } do
      expect do
        expect(Relaton::Iho::Bibliography.get("IHO B-1111")).to be_nil
      end.to output(/\[relaton-iho\] INFO: \(IHO B-1111\) Not found\./).to_stderr_from_any_process
    end
  end

  context "bib instance" do
    let(:yaml) { File.read "spec/fixtures/item.yaml", encoding: "UTF-8" }

    it "create item from yaml" do
      item = Relaton::Iho::Item.from_yaml yaml
      xml = item.to_xml bibdata: true
      file = "spec/fixtures/iho.xml"
      File.write file, xml, encoding: "UTF-8" unless File.exist? file
      expect(xml).to be_equivalent_to File.read(file, encoding: "UTF-8")
    end
  end

  it "check XML grammar" do
    schema = Jing.new "grammars/relaton-iho-compile.rng"
    errors = schema.validate "spec/fixtures/bibdata.xml"
    expect(errors).to eq []
  end
end

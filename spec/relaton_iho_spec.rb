RSpec.describe RelatonIho do
  it "has a version number" do
    expect(RelatonIho::VERSION).not_to be nil
  end

  it "retur grammar hash" do
    hash = RelatonIho.grammar_hash
    expect(hash).to be_instance_of String
    expect(hash.size).to eq 32
  end

  it "search a code" do
    VCR.use_cassette "b_11" do
      result = RelatonIho::IhoBibliography.search "IHO B-11"
      expect(result).to be_instance_of RelatonIho::IhoBibliographicItem
    end
  end

  context "get document" do
    it "by code" do
      VCR.use_cassette "b_11" do
        file = "spec/fixtures/b_11.xml"
        result = RelatonIho::IhoBibliography.get "IHO B-11"
        xml = result.to_xml bibdata: true
        File.write file, xml, encoding: "UTF-8" unless File.exist? file
        expect(xml).to be_equivalent_to File.read(file, encoding: "UTF-8")
          .sub(/(?<=<fetched>).*(?=<\/fetched>)/, Date.today.to_s)
        schema = Jing.new "grammars/relaton-iho-compile.rng"
        errors = schema.validate file
        expect(errors).to eq []
      end
    end

    it "by slightly misspelled reference" do
      VCR.use_cassette "iho_s63" do
        result = RelatonIho::IhoBibliography.get "IHO S63"
        expect(result.docidentifier.first.id).to eq "S-63"
      end
    end

    it "by code and edition", vcr: { cassette_name: "code_and_edition" } do
      result = RelatonIho::IhoBibliography.get "IHO B-6 4.2.0"
      expect(result.docidentifier.first.id).to eq "B-6"
      expect(result.edition.content).to eq "4.2.0"
    end
  end

  context "bib instance" do
    let(:hash) { YAML.load_file "spec/fixtures/iho.yaml" }
    let(:bib_hash) { RelatonIho::HashConverter.hash_to_bib hash }

    it "create item form hash" do
      item = RelatonIho::IhoBibliographicItem.new(**bib_hash)
      xml = item.to_xml bibdata: true
      file = "spec/fixtures/iho.xml"
      File.write file, xml, encoding: "UTF-8" unless File.exist? file
      expect(xml).to be_equivalent_to File.read(file, encoding: "UTF-8")
    end
  end

  it "check XML grammar" do
    schema = Jing.new "grammars/relaton-iho-compile.rng"
    errors = schema.validate "spec/fixtures/iho.xml"
    expect(errors).to eq []
  end
end

RSpec.describe RelatonIho::IhoBibliography do
  it "raise ReauestError" do
    expect(Net::HTTP).to receive(:get_response).and_raise SocketError
    expect do
      RelatonIho::IhoBibliography.search "ref"
    end.to raise_error RelatonBib::RequestError
  end

  it "returns AsciiBib" do
    hash = YAML.load_file "spec/fixtures/iho.yaml"
    bib_hash = RelatonIho::HashConverter.hash_to_bib hash
    item = RelatonIho::IhoBibliographicItem.new **bib_hash
    bib = item.to_asciibib
    file = "spec/fixtures/asciibib.adoc"
    File.write file, bib, encoding: "UTF-8" unless File.exist? file
    expect(bib).to eq File.read(file, encoding: "UTF-8")
  end
end

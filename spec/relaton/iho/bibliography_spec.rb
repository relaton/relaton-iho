RSpec.describe Relaton::Iho::Bibliography do
  it "raise RequestError" do
    expect(Relaton::Index).to receive(:find_or_create).and_raise SocketError
    # expect(Net::HTTP).to receive(:get_response).and_raise SocketError
    expect do
      Relaton::Iho::Bibliography.search "IHO B-11"
    end.to raise_error Relaton::RequestError
  end

  it "returns AsciiBib" do
    item = Relaton::Iho::Item.from_yaml File.read("spec/fixtures/item.yaml", encoding: "UTF-8")
    bib = item.to_asciibib
    file = "spec/fixtures/asciibib.adoc"
    File.write file, bib, encoding: "UTF-8" unless File.exist? file
    expect(bib).to eq File.read(file, encoding: "UTF-8")
  end
end

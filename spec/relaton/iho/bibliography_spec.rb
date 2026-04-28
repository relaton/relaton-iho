RSpec.describe Relaton::Iho::Bibliography do
  it "raise RequestError" do
    expect(Relaton::Index).to receive(:find_or_create).and_raise SocketError
    # expect(Net::HTTP).to receive(:get_response).and_raise SocketError
    expect do
      Relaton::Iho::Bibliography.search "IHO B-11"
    end.to raise_error Relaton::RequestError
  end

  it "returns nil when reference is not in the index" do
    expect(Net::HTTP).not_to receive(:get_response)
    expect(Relaton::Iho::Util).to receive(:info).with("Fetching from Relaton repository ...", key: "IHO B-99 99.0.0")
    expect(Relaton::Iho::Util).to receive(:info).with("Not found.", key: "IHO B-99 99.0.0")
    expect(Relaton::Iho::Bibliography.search("IHO B-99 99.0.0")).to be_nil
  end

  it "raises RequestError when HTTP response is not 200" do
    resp = instance_double(Net::HTTPResponse, code: "404")
    expect(Net::HTTP).to receive(:get_response).and_return(resp)
    expect do
      Relaton::Iho::Bibliography.search "IHO B-11"
    end.to raise_error(Relaton::RequestError, /HTTP 404/)
  end

  it "raises RequestError when the HTTP request fails with a network error" do
    expect(Net::HTTP).to receive(:get_response).and_raise(Net::ReadTimeout)
    expect do
      Relaton::Iho::Bibliography.search "IHO B-11"
    end.to raise_error(Relaton::RequestError, /Could not access/)
  end

  it "returns AsciiBib" do
    item = Relaton::Iho::Item.from_yaml File.read("spec/fixtures/item.yaml", encoding: "UTF-8")
    bib = item.to_asciibib
    file = "spec/fixtures/asciibib.adoc"
    File.write file, bib, encoding: "UTF-8" unless File.exist? file
    expect(bib).to eq File.read(file, encoding: "UTF-8")
  end
end

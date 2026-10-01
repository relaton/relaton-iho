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

RSpec.describe Relaton::Iho::Bibliography do
  describe ".select_latest" do
    it "selects the highest edition among index rows" do
      rows = %w[1.0.0 5.2.1 5.2.0 2.0.0].map do |version|
        { id: Pubid::Iho::Identifier.parse("IHO S-100 #{version}"),
          file: "data/s-100_#{version.tr('.', '-')}.yaml" }
      end
      expect(described_class.select_latest(rows)[:file])
        .to eq "data/s-100_5-2-1.yaml"
    end

    it "orders multi-digit editions numerically" do
      rows = %w[9.0.0 10.0.0].map do |version|
        { id: Pubid::Iho::Identifier.parse("IHO S-65 #{version}"),
          file: "data/s-65_#{version.tr('.', '-')}.yaml" }
      end
      expect(described_class.select_latest(rows)[:file])
        .to eq "data/s-65_10-0-0.yaml"
    end

    it "treats a missing version as older than any edition" do
      rows = [{ id: Pubid::Iho::Identifier.parse("IHO B-11"),
                file: "data/b-11.yaml" },
              { id: Pubid::Iho::Identifier.parse("IHO B-11 1.0.0"),
                file: "data/b-11_1-0-0.yaml" }]
      expect(described_class.select_latest(rows)[:file])
        .to eq "data/b-11_1-0-0.yaml"
    end
  end
end

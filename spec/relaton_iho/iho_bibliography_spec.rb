RSpec.describe RelatonIho::IhoBibliography do
  it "raise ReauestError" do
    expect(Net::HTTP).to receive(:get_response).and_raise SocketError
    expect do
      RelatonIho::IhoBibliography.search "ref"
    end.to raise_error RelatonBib::RequestError
  end
end

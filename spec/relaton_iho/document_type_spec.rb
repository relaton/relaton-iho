describe RelatonIho::DocumentType do
  it "warns if invalid doctype" do
    expect do
      described_class.new type: "invalid"
    end.to output(/\[relaton-iho\] WARNING: invalid doctype: `invalid`/).to_stderr
  end
end

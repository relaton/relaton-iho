describe RelatonIho::DocumentType do
  it "warns if invalid doctype" do
    expect do
      described_class.new type: "invalid"
    end.to output(/\[relaton-iho\] WARN: invalid doctype: `invalid`/).to_stderr_from_any_process
  end
end

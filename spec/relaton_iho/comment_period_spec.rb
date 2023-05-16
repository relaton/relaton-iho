RSpec.describe RelatonIho::CommentPeriond do
  it "to xml" do
    item = RelatonIho::IhoBibliographicItem.new(
      commentperiod: RelatonIho::CommentPeriond.new(
        from: "2015-03-11", to: "2018-01-01",
      ),
    )
    expect(item.to_xml(bibdata: true)).to be_equivalent_to <<~XML
      <bibdata schema-version="v1.2.3">
        <ext schema-version="v1.0.0">
          <commentperiod>
            <from>2015-03-11</from>
            <to>2018-01-01</to>
          </commentperiod>
        </ext>
      </bibdata>
    XML
  end
end

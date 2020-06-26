RSpec.describe RelatonIho::EditorialGroup do
  it "convert editorial group & comment period" do
    hash = {
      "editorialgroup" => { "committee" => "hssc", "workgroup" => "WG" },
      "commentperiod" => { "from" => "2011-02-01", "to" => "2015-12-31" },
      "fetched" => Date.today.to_s,
      "type" => "standard",
    }

    bib_hash = RelatonIho::HashConverter.hash_to_bib hash
    item = RelatonIho::IhoBibliographicItem.new bib_hash
    expect(item.to_hash).to eq hash
  end
end

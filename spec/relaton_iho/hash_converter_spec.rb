RSpec.describe RelatonIho::EditorialGroup do
  it "convert editorial group & comment period" do
    hash = {
      "editorialgroup" => [
        {
          "committee" => {
            "abbreviation" => "HSSC",
            "name" => "Hydrographic Services and Standards Committee",
            "workgroup" => {
              "abbreviation" => "S-100WG",
              "name" => "S-100 Working Group",
            },
          },
        },
        [
          {
            "committee" => {
              "abbreviation" => "IRCC",
              "name" => "Inter-Regional Coordination Committee",
              "commission" => {
                "abbreviation" => "RHCs",
                "name" => "Regional Hydrographic Commissions",
              },
            },
          },
          {
            "workgroup" => {
              "abbreviation" => "Council",
              "workgroup" => {
                "abbreviation" => "SPRWG",
                "name" => "Strategic Plan Review Working Group",
              },
            },
          },
        ],
      ],
      "commentperiod" => { "from" => "2011-02-01", "to" => "2015-12-31" },
      "fetched" => Date.today.to_s,
      "type" => "standard",
    }

    bib_hash = RelatonIho::HashConverter.hash_to_bib hash
    item = RelatonIho::IhoBibliographicItem.new **bib_hash
    expect(item.to_hash).to eq hash
  end
end

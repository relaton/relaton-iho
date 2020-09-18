RSpec.describe RelatonIho::IHOGroup do
  context "expand from abbreviatiom" do
    subject do
      RelatonIho::IHOGroup.expand "ICCWG"
    end

    it "and render XML" do
      xml = Nokogiri::XML::Builder.new do |b|
        subject.to_xml b
      end.doc.root.to_xml

      expect(xml).to be_equivalent_to <<~XML
        <committee>
          <name>Inter-Regional Coordination Committee</name>
          <abbreviation>IRCC</abbreviation>
          <commisstion>
            <name>Regional Hydrographic Commissions</name>
            <abbreviation>RHCs</abbreviation>
            <commisstion>
              <name>South-West Pacific HC</name>
              <abbreviation>SWPHC</abbreviation>
              <workgroup>
                <name>International Charting Coordination Working Group</name>
                <abbreviation>ICCWG</abbreviation>
              </workgroup>
            </commisstion>
          </commisstion>
        </committee>
      XML
    end

    it "and render AsciiBib" do
      ab = subject.to_asciibib "editorialgroup"
      expect(ab).to eq <<~ASCIIBIB
        editorialgroup.committee.abbreviation:: IRCC
        editorialgroup.committee.name:: Inter-Regional Coordination Committee
        editorialgroup.committee.commission.abbreviation:: RHCs
        editorialgroup.committee.commission.name:: Regional Hydrographic Commissions
        editorialgroup.committee.commission.commission.abbreviation:: SWPHC
        editorialgroup.committee.commission.commission.name:: South-West Pacific HC
        editorialgroup.committee.commission.commission.workgroup.abbreviation:: ICCWG
        editorialgroup.committee.commission.commission.workgroup.name:: International Charting Coordination Working Group
      ASCIIBIB
    end
  end
end

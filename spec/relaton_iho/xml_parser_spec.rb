RSpec.describe RelatonIho::XMLParser do
  it "create item from XML" do
    xml = File.read "spec/fixtures/iho.xml", encoding: "UTF-8"
    item = RelatonIho::XMLParser.from_xml xml
    expect(item.to_xml(bibdata: true)).to be_equivalent_to xml
  end

  it "create_doctype" do
    elm = Nokogiri::XML("<doctype abbreviation='ST'>standard</doctype>").root
    dt = RelatonIho::XMLParser.send :create_doctype, elm
    expect(dt).to be_instance_of RelatonIho::DocumentType
    expect(dt.type).to eq "standard"
    expect(dt.abbreviation).to eq "ST"
  end
end

module Relaton
  module Iho
    class Bibdata < Item
      model ItemData
      include Bib::BibdataShared
    end
  end
end

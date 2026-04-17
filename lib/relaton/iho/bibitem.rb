module Relaton
  module Iho
    class Bibitem < Item
      model ItemData
      include Bib::BibitemShared
    end
  end
end

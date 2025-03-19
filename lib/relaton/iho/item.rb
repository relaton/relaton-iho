require_relative "ext"

module Relaton
  module Iho
    class  Item < Bib::Item
      model Bib::ItemData

      attribute :ext, Ext
    end
  end
end

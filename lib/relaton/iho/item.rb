require_relative "item_data"
require_relative "ext"
require_relative "docidentifier"

module Relaton
  module Iho
    class Item < Bib::Item
      model ItemData

      attribute :ext, Ext
      attribute :docidentifier, Docidentifier, collection: true,
                                               initialize_empty: true
    end
  end
end

require_relative "relation"

Relaton::Iho::Item.attribute :relation, Relaton::Iho::Relation,
                             collection: true, initialize_empty: true

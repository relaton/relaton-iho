module Relaton
  module Iho
    class StructuredIdentifier < Lutaml::Model::Serializable
      attribute :docnumber, :string
      attribute :part, :string
      attribute :annexid, :string
      attribute :appendixid, :string
      attribute :supplementid, :string

      xml do
        root "structuredidentifier"
        map_element "docnumber", to: :docnumber
        map_element "part", to: :part
        map_element "annexid", to: :annexid
        map_element "appendixid", to: :appendixid
        map_element "supplementid", to: :supplementid
      end
    end
  end
end

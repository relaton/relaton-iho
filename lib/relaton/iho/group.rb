module Relaton
  module Iho
    class Group < Lutaml::Model::Serializable
    end

    class Group
      attribute :name, :string
      attribute :abbreviation, :string
      choice(min: 0, max: 1) do
        attribute :committee, Group
        attribute :workgroup, Group
        attribute :commission, Group
      end

      xml do
        map_element "name", to: :name
        map_element "abbreviation", to: :abbreviation
        map_element "committee", to: :committee
        map_element "workgroup", to: :workgroup
        map_element "commission", to: :commission
      end
    end
  end
end

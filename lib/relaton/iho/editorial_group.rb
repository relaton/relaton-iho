require_relative "group"

module Relaton
  module Iho
    class EditorialGroup < Lutaml::Model::Serializable
      choice(min: 1, max: Float::INFINITY) do
        attribute :committee, Group, collection: true
        attribute :workgroup, Group, collection: true
        attribute :commission, Group, collection: true
      end

      xml do
        map_element "committee", to: :committee
        map_element "workgroup", to: :workgroup
        map_element "commission", to: :commission
      end
    end
  end
end

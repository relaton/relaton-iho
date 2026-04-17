require_relative "doctype"
require_relative "comment_period"

module Relaton
  module Iho
    class Ext < Bib::Ext
      attribute :doctype, Doctype, default: -> { Doctype.new(content: "standard") }
      attribute :commentperiod, CommentPeriod

      xml { map_element "commentperiod", to: :commentperiod }

      key_value { map_element "commentperiod", to: :commentperiod }

      def schema_version
        Relaton.schema_versions["relaton-model-iho"]
      end
    end
  end
end

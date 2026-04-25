require_relative "doctype"
require_relative "comment_period"
require_relative "structured_identifier"

module Relaton
  module Iho
    class Ext < Bib::Ext
      attribute :doctype, Doctype, default: -> { Doctype.new(content: "standard") }
      attribute :commentperiod, CommentPeriod
      attribute :structuredidentifier, StructuredIdentifier,
                collection: true, initialize_empty: true

      xml do
        map_element "commentperiod", to: :commentperiod
      end

      def schema_version
        Relaton.schema_versions["relaton-model-iho"]
      end
    end
  end
end

module Relaton
  module Iho
    class Docidentifier < Bib::Docidentifier
      attr_reader :pubid

      def initialize(attrs = {}, options = {})
        pubid = attrs.is_a?(Hash) ? attrs.delete(:pubid) : nil
        attrs[:content] ||= pubid.to_s if pubid
        super
        @pubid = pubid if pubid
      end

      def content=(value)
        super
        @pubid = ::Pubid::Iho::Identifier.parse(value) if value
      end

      def to_h
        @pubid&.to_h || super
      end

      def remove_part!
        @pubid&.part = nil
      end

      def remove_date!
        @pubid&.year = nil
      end

      def to_all_parts!
        @pubid&.all_parts = true
      end
    end
  end
end

require "relaton/processor"

module RelatonIho
  class Processor < Relaton::Processor
    attr_reader :idtype

    def initialize
      @short = :relaton_iho
      @prefix = "IHO"
      @defaultprefix = %r{^IHO\s}
      @idtype = "IHO"
    end

    # @param code [String]
    # @param date [String, NilClass] year
    # @param opts [Hash]
    # @return [RelatonIho::IhoBibliographicItem]
    def get(code, date, opts)
      ::RelatonIho::IhoBibliography.get(code, date, opts)
    end

    # @param xml [String]
    # @return [RelatonIho::IhoBibliographicItem]
    def from_xml(xml)
      ::RelatonIho::XMLParser.from_xml xml
    end

    # @param hash [Hash]
    # @return [RelatonIho::IhoBibliographicItem]
    def hash_to_bib(hash)
      item_hash = ::RelatonIho::HashConverter.hash_to_bib(hash)
      ::RelatonIho::IhoBibliographicItem.new item_hash
    end

    # Returns hash of XML grammar
    # @return [String]
    def grammar_hash
      @grammar_hash ||= ::RelatonIeee.grammar_hash
    end
  end
end
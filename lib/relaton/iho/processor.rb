require "relaton/core/processor"

module Relaton
  module Iho
    class Processor < Core::Processor
      attr_reader :idtype

      def initialize
        @short = :relaton_iho
        @prefix = "IHO"
        @defaultprefix = %r{^IHO\s}
        @idtype = "IHO"
      end

      # @param code [String]
      # @param date [String, nil] year
      # @param opts [Hash]
      # @return [Relaton::Iho::ItemData, nil]
      def get(code, date, opts)
        require_relative "../iho"
        Bibliography.get(code, date, opts)
      end

      # @param xml [String]
      # @return [Relaton::Iho::ItemData]
      def from_xml(xml)
        require_relative "../iho"
        Item.from_xml xml
      end

      # @param yaml [String]
      # @return [Relaton::Iho::ItemData]
      def from_yaml(yaml)
        require_relative "../iho"
        Item.from_yaml(yaml)
      end

      # Returns hash of XML grammar
      # @return [String]
      def grammar_hash
        require_relative "../iho"
        @grammar_hash ||= ::Relaton::Iho.grammar_hash
      end

      #
      # Remove index file
      #
      def remove_index_file
        require_relative "../iho"
        Relaton::Index.find_or_create(:iho, url: true, file: "#{INDEXFILE}.yaml").remove_file
      end
    end
  end
end

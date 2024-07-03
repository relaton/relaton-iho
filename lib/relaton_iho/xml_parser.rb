module RelatonIho
  class XMLParser < RelatonBib::XMLParser
    class << self
      private

      # Override RelatonBib::XMLParser.item_data method.
      # @param item [Nokogiri::XML::Element]
      # @returtn [Hash]
      def item_data(item)
        data = super
        ext = item.at "./ext"
        return data unless ext

        data[:commentperiod] = fetch_commentperiond ext
        data
      end

      # @param item_hash [Hash]
      # @return [RelatonIho::IhoBibliographicItem]
      def bib_item(item_hash)
        IhoBibliographicItem.new(**item_hash)
      end

      # @param ext [Nokogiri::XML::Element, nil]
      # @return [RelatonIho::EditorialGroupCollection, nil]
      def fetch_editorialgroup(ext)
        return unless ext

        egs = ext.xpath("editorialgroup").map do |eg|
          grps = eg.xpath("committee|workgroup|commission").map do |ig|
            iho_group ig
          end
          EditorialGroup.new grps
        end
        EditorialGroupCollection.new egs if egs.any?
      end

      # @param ihgrp [Nokogiri::XML::Element, nil]
      # @return [RelatonIho::Committee, RelatonIho::Commission,
      #   RelatonIho::Workgroup, nil]
      def iho_group(ihgrp)
        return unless ihgrp

        klass = Object.const_get "RelatonIho::" + ihgrp.name.capitalize
        subg = iho_group ihgrp.at("./committee|./workgroup|./commission")
        klass.new ihgrp.at("abbreviation").text, ihgrp.at("name")&.text, subg
      end

      # @param ext [Nokogiri::XML::Element]
      # @return [RelatonIho::CommentPeriod, nil]
      def fetch_commentperiond(ext)
        return unless ext && (cp = ext.at "commentperiod")

        CommentPeriond.new from: cp.at("from")&.text, to: cp.at("to")&.text
      end

      def create_doctype(type)
        DocumentType.new type: type.text, abbreviation: type[:abbreviation]
      end
    end
  end
end

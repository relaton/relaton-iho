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
        IhoBibliographicItem.new item_hash
      end

      # @param ext [Nokogiri::XML::Element]
      # @return [RelatonIho::EditorialGroupCollection, nil]
      def fetch_editorialgroup(ext)
        return unless ext

        egs = ext.xpath("editorialgroup").map do |eg|
          EditorialGroup.new(committee: eg.at("committee")&.text,
                             workgroup: eg.at("workgroup")&.text)
        end
        EditorialGroupCollection.new egs if egs.any?
      end

      # @param ext [Nokogiri::XML::Element]
      # @return [RelatonIho::CommentPeriod, nil]
      def fetch_commentperiond(ext)
        return unless ext && (cp = ext.at "commentperiod")

        CommentPeriond.new from: cp.at("from")&.text, to: cp.at("to")&.text
      end
    end
  end
end

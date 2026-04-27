require "relaton/bib/hash_parser_v1"
require_relative "../iho"

module Relaton
  module Iho
    module HashParserV1
      include Core::ArrayWrapper
      include Core::DateParser
      include Bib::HashParserV1
      extend self

      private

      def ext_hash_to_bib(ret) # rubocop:disable Metrics/AbcSize
        ret[:ext] ||= {}
        doctype_hash_to_bib ret
        ret[:ext][:doctype] ||= Doctype.new(content: "standard")
        ret[:ext][:subdoctype] = ret.delete(:subdoctype) if ret[:subdoctype]
        ret[:ext][:flavor] ||= flavor(ret)
        ics_hash_to_bib ret
        commentperiod_hash_to_bib ret
        structuredidentifier_hash_to_bib ret
        ret[:ext] = Ext.new(**ret[:ext])
      end

      def structuredidentifier_hash_to_bib(ret)
        sid = ret.dig(:ext, :structuredidentifier) || ret[:structuredidentifier]
        return unless sid

        ret[:ext]&.delete(:structuredidentifier)
        ret.delete(:structuredidentifier)
        ret[:ext][:structuredidentifier] =
          array(sid).map { |s| StructuredIdentifier.new(**s) }
      end

      def commentperiod_hash_to_bib(ret)
        cp = ret.dig(:ext, :commentperiod) || ret[:commentperiod]
        return unless cp

        ret[:ext]&.delete(:commentperiod)
        ret.delete(:commentperiod)
        cp[:from] = ::Date.parse(cp[:from]) if cp[:from]
        cp[:to] = ::Date.parse(cp[:to]) if cp[:to]
        ret[:ext][:commentperiod] = CommentPeriod.new(**cp)
      end

      # IHO editorialgroup is an array of arrays of committee entries:
      #   editorialgroup:
      #   - - committee:
      #         abbreviation: HSSC
      #         name: Hydrographic Services and Standards Committee
      #     - committee:
      #         abbreviation: IRCC
      #         name: Inter-Regional Coordination Committee
      #         committee:
      #           abbreviation: GEBCO
      #           name: JOINT IHO-IOC GUIDING COMMITTEE FOR THE GENERAL BATHYMETRIC CHART OF THE OCEANS
      def editorialgroup_hash_to_bib(ret) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
        eg = ret.dig(:ext, :editorialgroup) || ret[:editorialgroup]
        return unless eg

        ret[:ext]&.delete(:editorialgroup)
        ret.delete(:editorialgroup)
        ret[:contributor] ||= []

        array(eg).flatten.each do |entry|
          committee = entry[:committee]
          next unless committee

          subdivision = build_subdivision(committee)
          ret[:contributor] << Bib::Contributor.new(
            role: [Bib::Contributor::Role.new(
              type: "author",
              description: [Bib::LocalizedMarkedUpString.new(content: "committee")],
            )],
            organization: Bib::Organization.new(
              name: [Bib::TypedLocalizedString.new(content: "International Hydrographic Organization")],
              abbreviation: Bib::LocalizedString.new(content: "IHO"),
              subdivision: [subdivision],
            ),
          )
        end
      end

      def build_subdivision(committee)
        sub_divisions = []
        if committee[:committee]
          sub_divisions << build_subdivision(committee[:committee])
        end

        identifiers = []
        if committee[:abbreviation]
          identifiers << Bib::OrganizationType::Identifier.new(
            content: committee[:abbreviation],
          )
        end

        Bib::Subdivision.new(
          type: "technical-committee",
          name: [Bib::TypedLocalizedString.new(content: committee[:name])],
          identifier: identifiers,
          subdivision: sub_divisions,
        )
      end

      def series_hash_to_bib(ret)
        ret[:series] &&= array(ret[:series]).map do |s|
          if s[:title].is_a?(Hash) && s[:title][:content].is_a?(Array)
            s[:title] = s[:title][:content].map do |c|
              { type: s[:title][:type], content: c[:content], language: c[:language], script: c[:script] }.compact
            end
          end
          super_series(s)
        end
      end

      def super_series(s)
        s[:formattedref] && s[:formattedref] = formattedref(s[:formattedref])
        s[:title] &&= title_collection(s[:title])
        s[:place] &&= create_place(s[:place])
        s[:abbreviation] &&= localizedstring(s[:abbreviation])
        s[:from] &&= ::Date.parse(s[:from])
        s[:to] &&= ::Date.parse(s[:to])
        Bib::Series.new(**s)
      end

      def bib_item(item)
        ItemData.new(**item)
      end

      def create_doctype(args)
        Doctype.new(**args)
      end

      def create_relation(rel)
        Relation.new(**rel)
      end

      def create_docid(**args)
        Docidentifier.new(**args)
      end
    end
  end
end

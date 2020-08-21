module RelatonIho
  class IhoBibliographicItem < RelatonBib::BibliographicItem
    TYPES = %w[policy-and-procedures best-practices supporting-document
               report legal directives proposal standard].freeze

    # @return [RelatonIho::CommentPeriod, NilClass]
    attr_reader :commentperiod

    # @param editorialgroup [RelatonIho::EditorialGroupCollection]
    # @param commentperiod [RelatonIho::CommentPeriod, NilClass]
    def initialize(**args)
      @commentperiod = args.delete :commentperiod
      super
    end

    # @param builder [Nokogiri::XML::Builder]
    # @param bibdata [TrueClasss, FalseClass, NilClass]
    def to_xml(builer = nil, **opts) # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
      opts[:ext] = !commentperiod.nil?
      super do |b|
        if opts[:bibdata] && (doctype || editorialgroup&.presence? ||
                              ics.any? || commentperiod)
          b.ext do
            b.doctype doctype if doctype
            editorialgroup&.to_xml b
            ics.each { |i| i.to_xml b }
            commentperiod&.to_xml b
          end
        end
      end
    end

    # @return [Hash]
    def to_hash
      hash = super
      hash["commentperiod"] = commentperiod.to_hash if commentperiod
      hash
    end

    # @param prefix [String]
    # @return [String]
    def to_asciibib(prefix = "")
      out = super
      out += commentperiod.to_asciibib prefix if commentperiod
      out
    end
  end
end

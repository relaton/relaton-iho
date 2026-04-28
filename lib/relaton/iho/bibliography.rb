require "net/http"

module Relaton
  module Iho
      module Bibliography
      ENDPOINT = "https://raw.githubusercontent.com/relaton/relaton-data-iho/refs/heads/data-v2/".freeze

      class << self
        #
        # Search for IHO standard by IHO standard Code
        #
        # @param text [String] the IHO standard Code to look up (e..g "IHO B-11")
        #
        # @return [RelatonIho::IhoBibliographicItem, nil] the IHO standard or nil if not found
        #
        def search(text, _year = nil, _opts = {}) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
          pubid = text.is_a?(String) ? ::Pubid::Iho::Identifier.parse(text) : text
          Util.info "Fetching from Relaton repository ...", key: pubid.to_s
          ref = pubid.to_s.sub(/^IHO\s/, "")
          index = Relaton::Index.find_or_create :iho, url: "#{ENDPOINT}#{INDEXFILE}.zip"
          row = index.search(ref).min_by { |r| r[:id] }
          unless row
            Util.info "Not found.", key: pubid.to_s
            return
          end

          uri = URI("#{ENDPOINT}#{row[:file]}")
          resp = Net::HTTP.get_response uri
          unless resp.code == "200"
            raise Relaton::RequestError, "Could not access #{uri}: HTTP #{resp.code}"
          end

          item = Relaton::Iho::Item.from_yaml resp.body
          enrich_with_pubid(item, pubid)
          Util.info "Found: `#{item.docidentifier.first.content}`", key: pubid.to_s
          item.tap { |i| i.fetched = Date.today.to_s }
        rescue SocketError, Errno::EINVAL, Errno::ECONNRESET, EOFError,
              Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
              Net::ProtocolError, Net::ReadTimeout, OpenSSL::SSL::SSLError,
              Errno::ETIMEDOUT => e
          raise Relaton::RequestError, "Could not access #{uri}: #{e.message}"
        end

        # Populate ext.structuredidentifier from the parsed Pubid when the
        # fetched record doesn't already provide one. Maps `pubid.number`
        # (with type prefix, e.g. `S-100`) -> docnumber, `pubid.part` -> part,
        # `pubid.appendix` -> appendixid. annexid/supplementid stay
        # unpopulated until pubid-iho exposes them.
        def enrich_with_pubid(item, pubid)
          return if item.ext&.structuredidentifier&.any?

          sid = StructuredIdentifier.new(
            docnumber: pubid_docnumber(pubid),
            part: pubid.part,
            appendixid: (pubid.appendix if pubid.respond_to?(:appendix)),
          )
          item.ext ||= Ext.new
          item.ext.structuredidentifier = [sid]
        end

        # "S-100" rather than "100" — keeps the type prefix that distinguishes
        # the IHO series (S/P/M/B/C). Matches spec/fixtures/iho_part.xml.
        def pubid_docnumber(pubid)
          pubid.to_s.sub(/^IHO\s/, "").split(/\s+/, 2).first
        end

        # @param ref [String] the IHO standard Code to look up (e..g "IHO B-11")
        # @param year [String] the year the standard was published (optional)
        #
        # @param opts [Hash] options
        # @option opts [TrueClass, FalseClass] :all_parts restricted to all parts
        #   if all-parts reference is required
        # @option opts [TrueClass, FalseClass] :bibdata
        #
        # @return [RelatonIho::IhoBibliographicItem]
        def get(ref, year = nil, opts = {})
          search(ref, year, opts)
        end
      end
    end
  end
end

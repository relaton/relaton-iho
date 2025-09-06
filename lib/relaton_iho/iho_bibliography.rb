require "net/http"

module RelatonIho
  class IhoBibliography
    ENDPOINT = "https://raw.githubusercontent.com/relaton/relaton-data-iho/" \
               "main/".freeze

    class << self
      #
      # Search for IHO standard by IHO standard Code
      #
      # @param text [String] the IHO standard Code to look up (e..g "IHO B-11")
      #
      # @return [RelatonIho::IhoBibliographicItem, nil] the IHO standard or nil if not found
      #
      def search(text, _year = nil, _opts = {}) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        Util.info "Fetching from Relaton repository ...", key: text
        ref = text.sub(/^IHO\s/, "").sub(/^([[:alpha:]]+)(\d+)/, '\1-\2')
        index = Relaton::Index.find_or_create :iho, url: "#{ENDPOINT}index.zip"
        row = index.search(ref).min_by { |r| r[:id] }
        unless row
          Util.info "Not found.", key: text
          return
        end

        uri = URI("#{ENDPOINT}#{row[:file]}")
        resp = Net::HTTP.get_response uri
        unless resp.code == "200"
          raise RelatonBib::RequestError, "Could not access #{uri}: HTTP #{resp.code}"
        end

        yaml = RelatonBib.parse_yaml resp.body, [Date]
        hash = HashConverter.hash_to_bib yaml
        hash[:fetched] = Date.today.to_s
        item = IhoBibliographicItem.new(**hash)
        Util.info "Found: `#{item.docidentifier.first.id}`", key: text
        item
      rescue SocketError, Errno::EINVAL, Errno::ECONNRESET, EOFError,
             Net::HTTPBadResponse, Net::HTTPHeaderSyntaxError,
             Net::ProtocolError, Net::ReadTimeout, OpenSSL::SSL::SSLError,
             Errno::ETIMEDOUT => e
        raise RelatonBib::RequestError, "Could not access #{uri}: #{e.message}"
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

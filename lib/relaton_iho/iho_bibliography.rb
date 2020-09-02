require "net/http"

module RelatonIho
  class IhoBibliography
    ENDPOINT = "https://raw.githubusercontent.com/relaton/relaton-data-iho/"\
               "master/data/".freeze

    class << self
      # @param text [String]
      # @return [RelatonIho::IhoBibliographicItem]
      def search(text, _year = nil, _opts = {}) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
        warn "[relaton-iho] (\"#{text}\") fetching..."
        ref = text.sub(/^IHO\s/, "").downcase.sub /^([[:alpha:]]+)(\d+)/, '\1-\2'
        uri = URI("#{ENDPOINT}#{ref}.yaml")
        resp = Net::HTTP.get_response uri
        return unless resp.code == "200"

        hash = HashConverter.hash_to_bib YAML.safe_load(resp.body, [Date])
        item = IhoBibliographicItem.new hash
        warn "[relaton-iho] (\"#{text}\") found #{item.docidentifier.first.id}"
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

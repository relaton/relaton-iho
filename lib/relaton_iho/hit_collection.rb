require "faraday"
require "yaml"
require "fileutils"

module RelatonIho
  class HitCollection < RelatonBib::HitCollection
    ENDPOINT = "https://raw.githubusercontent.com/relaton/relaton-data-iho/master/data/".freeze

    # @param ref [Strig]
    # @param year [String]
    # @param opts [Hash]
    def initialize(ref, year = nil)
      super
      @array = from_yaml(ref).sort_by do |hit|
        hit.hit["revdate"] ? Date.parse(hit.hit["revdate"]) : Date.new
      end.reverse
    end

    private

    #
    # Fetch data form yaml
    #
    # @param docid [String]
    def from_yaml(docid, **_opts)
      data["root"]["items"].select do |doc|
        doc["docid"] && doc["docid"]["id"].include?(docid)
      end.map { |h| Hit.new(h, self) }
    end

    #
    # Fetches YAML data
    #
    # @return [Hash]
    def data
      FileUtils.mkdir_p DATADIR
      ctime = File.ctime DATAFILE if File.exist? DATAFILE
      fetch_data if !ctime || ctime.to_date < Date.today
      @data ||= YAML.safe_load File.read(DATAFILE, encoding: "UTF-8")
    end

    #
    # fetch data form server and save it to file.
    #
    def fetch_data
      resp = Faraday.new(ENDPOINT, headers: { "If-None-Match" => etag }).get
      # return if there aren't any changes since last fetching
      return unless resp.status == 200

      self.etag = resp[:etag]
      @data = YAML.safe_load resp.body
      File.write DATAFILE, @data.to_yaml, encoding: "UTF-8"
    end

    #
    # Read ETag form file
    #
    # @return [String, NilClass]
    def etag
      @etag ||= if File.exist? ETAGFILE
                  File.read ETAGFILE, encoding: "UTF-8"
                end
    end

    #
    # Save ETag to file
    #
    # @param tag [String]
    def etag=(e_tag)
      File.write ETAGFILE, e_tag, encoding: "UTF-8"
    end
  end
end

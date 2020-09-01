module RelatonIho
  class IHOGroup
    # @return [String]
    attr_reader :abbreviation

    # @return [String, nil]
    attr_reader :name

    # @return [RelatonIho::Committee, RelatonIho::Workgroup,
    #          RelatonIho::Commission, nil]
    attr_reader :subgroup

    # @param abbreviation [String]
    # @param name [String, nil]
    # @param subgroup [RelatonIho::Committee, RelatonIho::Workgroup,
    #                  RelatonIho::Commission, nil]
    def initialize(abbreviation, name = nil, subgroup = nil)
      @abbreviation = abbreviation
      @name = name
      @subgroup = subgroup
    end

    class << self
      # @param abbr [String]
      # @return [RelatonIho::EditorialGroup]
      def expand(abbr)
        struct = YAML.load_file File.expand_path("eg.yml", __dir__)
        from_abbr abbr.upcase, struct
      end

      private

      # @param abbr [String]
      # @param struct [Hash]
      # @return [RelatonIho::Committee, RelatonIho::Commission,
      #          RelatonIho::Workgroup]
      def from_abbr(abbr, struct)
        return unless struct

        gr = struct.detect { |k, v| k == abbr || v["previously"] == abbr }
        return klass(gr[1]["class"]).new abbr, gr[1]["name"] if gr

        expand_from_abbr abbr, struct
      end

      # @param abbr [String]
      # @param struct [Hash]
      # @return [RelatonIho::Committee, RelatonIho::Commission,
      #          RelatonIho::Workgroup]
      def expand_from_abbr(abbr, struct)
        struct.each do |k, g|
          wg = from_abbr abbr, g["subgroup"]
          return klass(g["class"]).new k, g["name"], wg if wg
        end
        nil
      end

      def klass(name)
        Object.const_get "RelatonIho::" + name
      end
    end

    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.name name if name
      builder.abbreviation abbreviation
      subgroup&.to_xml builder
    end

    # @return [Hash]
    def to_hash
      hash = { "abbreviation" => abbreviation }
      hash["name"] = name if name
      hash.merge! subgroup.to_hash if subgroup
      hash
    end

    # @param prefix [String]
    # @param count [Integer]
    # @return [Strin]
    def to_asciibib(prefix, count = 1)
      out = count > 1 ? "#{prefix}::\n" : ""
      out += "#{prefix}.abbreviation:: #{abbreviation}\n"
      out += "#{prefix}.name:: #{name}\n" if name
      out += subgroup.to_asciibib prefix if subgroup
      out
    end
  end

  class Committee < IHOGroup
    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.committee { |b| super b }
    end

    # @return [Hash]
    def to_hash
      { "committee" => super }
    end

    # @param prefix [String]
    # @param count [Integer]
    # @return [Strin]
    def to_asciibib(prefix, count = 1)
      super prefix + ".committee", count
    end
  end

  class Workgroup < IHOGroup
    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.workgroup { |b| super b }
    end

    # @return [Hash]
    def to_hash
      { "workgroup" => super }
    end

    # @param prefix [String]
    # @param count [Integer]
    # @return [Strin]
    def to_asciibib(prefix, count = 1)
      super prefix + ".workgroup", count
    end
  end

  class Commission < IHOGroup
    # @param builder [Nokogiri::XML::Builder]
    def to_xml(builder)
      builder.commisstion { |b| super b }
    end

    # @return [Hash]
    def to_hash
      { "commission" => super }
    end

    # @param prefix [String]
    # @param count [Integer]
    # @return [Strin]
    def to_asciibib(prefix, count = 1)
      super prefix + ".commission", count
    end
  end
end

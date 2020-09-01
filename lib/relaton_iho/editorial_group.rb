module RelatonIho
  class EditorialGroupCollection
    extend Forwardable

    def_delegators :@collection, :first, :any?

    # @return [Array<RelatonIho::EditorialGroup]
    attr_reader :collection

    # @param collection [Array<RelatonIho::EditorialGroup>]
    def initialize(collection)
      @collection = collection
    end

    # @param builder [Nokogiro::XML::Builder]
    def to_xml(builder)
      collection.each { |eg| eg.to_xml builder }
    end

    # @return [Hash, Array<Hash>]
    def to_hash
      collection.map &:to_hash
    end

    # @param prefix [String]
    # @return [String]
    def to_asciibib(prefix)
      collection.map { |ed| ed.to_asciibib prefix, collection.size }.join
    end

    # @return [Boolean]
    def presence?
      any?
    end
  end

  class EditorialGroup
    include RelatonBib

    # @return [Array<RelatonIho::Committee, RelatonIho::Commission,
    #          RelatonIho::Workgroup>]
    attr_accessor :workgroup

    # @param workgroup [Array<RelatonIho::Committee, RelatonIho::Commission,
    #                   RelatonIho::Workgroup>]
    def initialize(workgroup)
      @workgroup = workgroup
    end

    # @param builder [Nokogiro::XML::Builder]
    def to_xml(builder)
      builder.editorialgroup do
        workgroup.each { |wg| wg.to_xml builder }
      end
    end

    # @return [Hash, Array<Hash>]
    def to_hash
      single_element_array workgroup
    end

    # @param prefix [String]
    # @param count [Integer]
    # @return [Strin]
    def to_asciibib(prefix, count)
      pref = prefix.empty? ? prefix : prefix + "."
      pref += "editorialgroup"
      out = count > 1 ? "#{pref}::\n" : ""
      workgroup.each { |wg| out += wg.to_asciibib pref, workgroup.size }
      out
    end
  end
end

module RelatonIho
  class EditorialGroupCollection
    extend Forwardable
    include RelatonBib

    def_delegators :@collection, :first, :any?

    # @return [Array<RelatonIho::editorialgroup]
    attr_reader :collection

    # @param collection [Array<RelatonIho::EditorialGroup>]
    def initialize(collection)
      @collection = collection
    end

    # @param builder [Nokogiro::XML::Builder]
    def to_xml(builder)
      collection.each { |eg| eg.to_xml builder }
    end

    # @return [Hash]
    def to_hash
      single_element_array collection
    end

    # @return [Boolean]
    def presence?
      any?
    end
  end

  class EditorialGroup
    # @return [String]
    attr_reader :committee

    # @return [String, nil]
    attr_reader :workgroup

    # @parma committee [String]
    # @param workgroup [String, nil]
    def initialize(committee:, workgroup: nil)
      unless %[hssc ircc].include? committee.downcase
        warn "[relaton-iho] WARNING: invalid committee: #{committee}"
      end
      @committee = committee
      @workgroup = workgroup
    end

    # @param builder [Nokogiro::XML::Builder]
    def to_xml(builder)
      builder.editorialgroup do
        builder.committee committee
        builder.workgroup workgroup if workgroup
      end
    end

    # @return [Hash]
    def to_hash
      hash = { "committee" => committee }
      hash["workgroup"] = workgroup if workgroup
      hash
    end
  end
end

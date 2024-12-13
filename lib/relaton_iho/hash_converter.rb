module RelatonIho
  module HashConverter
    include RelatonBib::HashConverter
    extend self
    # @override RelatonIsoBib::HashConverter.hash_to_bib
    # @param args [Hash]
    # @param nested [TrueClass, FalseClass]
    # @return [Hash]
    def hash_to_bib(args)
      ret = super
      return if ret.nil?

      commentperiod_hash_to_bib ret
      ret
    end

    private

    # @param item_hash [Hash]
    # @return [RelatonBib::BibliographicItem]
    def bib_item(**item_hash)
      IhoBibliographicItem.new(**item_hash)
    end

    # @param ret [Hash]
    def commentperiod_hash_to_bib(ret)
      cp = ret.dig(:ext, :commentperiod) || ret[:commentperiod] # @TODO remove ret[:commentperiod] after all gems are updated
      return unless cp

      ret[:commentperiod] = CommentPeriond.new(**cp)
    end

    # @param ret [Hash]
    def editorialgroup_hash_to_bib(ret)
      eg = ret.dig(:ext, :editorialgroup) || ret[:editorialgroup] # @TODO remove ret[:editorialgroup] after all gems are updated
      return unless eg.is_a?(Hash) || eg&.any?

      collection = RelatonBib.array(eg).map do |g|
        EditorialGroup.new(RelatonBib.array(g).map { |wg| iho_workgroup wg })
      end
      ret[:editorialgroup] = EditorialGroupCollection.new collection
    end

    # @param ihowg [Hash]
    # @return [RelatonIho::Committee, RelatonIho::Workgroup,
    #          RelatonIho::Commission]
    def iho_workgroup(ihowg)
      key, value = ihowg&.first
      return unless key && value.is_a?(Hash)

      klass = Object.const_get "RelatonIho::#{key.capitalize}"
      wgs = %i[committee workgroup commission]
      subwg = value.select { |k, _| wgs.include? k }
      klass.new value[:abbreviation], value[:name], iho_workgroup(subwg)
    end

    def create_doctype(**args)
      DocumentType.new(**args)
    end
  end
end

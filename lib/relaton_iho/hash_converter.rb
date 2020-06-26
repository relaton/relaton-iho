module RelatonIho
  class HashConverter < RelatonBib::HashConverter
    class << self
      # @override RelatonIsoBib::HashConverter.hash_to_bib
      # @param args [Hash]
      # @param nested [TrueClass, FalseClass]
      # @return [Hash]
      def hash_to_bib(args, nested = false)
        ret = super
        return if ret.nil?

        commentperiod_hash_to_bib ret
        ret
      end

      private

      # @param ret [Hash]
      def commentperiod_hash_to_bib(ret)
        ret[:commentperiod] &&= CommentPeriond.new(ret[:commentperiod])
      end

      # @param ret [Hash]
      def editorialgroup_hash_to_bib(ret)
        eg = ret[:editorialgroup]
        return unless eg.is_a?(Hash) || eg&.any?

        collection = array(eg).map { |g| EditorialGroup.new g }
        ret[:editorialgroup] = EditorialGroupCollection.new collection
      end
    end
  end
end

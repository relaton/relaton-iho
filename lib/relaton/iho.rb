require "relaton/bib"
require "relaton/index"
require "pubid/iho"
require_relative "iho/version"
require_relative "iho/util"
require_relative "iho/docidentifier"
require_relative "iho/item"
require_relative "iho/bibitem"
require_relative "iho/bibdata"
require_relative "iho/bibliography"

module Relaton
  module Iho
    INDEXFILE = "index-v1".freeze

    class Error < StandardError; end

    # Returns hash of XML reammar
    # @return [String]
    def self.grammar_hash
      # gem_path = File.expand_path "..", __dir__
      # grammars_path = File.join gem_path, "grammars", "*"
      # grammars = Dir[grammars_path].sort.map { |gp| File.read gp }.join
      Digest::MD5.hexdigest Relaton::Iho::VERSION + Relaton::Bib::VERSION # grammars
    end
  end
end

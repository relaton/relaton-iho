require "digest/md5"
require "yaml"
require "relaton/bib"
require "relaton/index"
require_relative "iho/version"
require_relative "iho/util"
# require "relaton_iho/document_type"
# require "relaton_iho/iho_bibliography"
# require "relaton_iho/hash_converter"
# require "relaton_iho/xml_parser"
# require "relaton_iho/editorial_group"
# require "relaton_iho/iho_group"
# require "relaton_iho/comment_periond"
require_relative "iho/item"
require_relative "iho/bibitem"
require_relative "iho/bibdata"

module Relaton
  module Iho
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

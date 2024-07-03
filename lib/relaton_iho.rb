require "digest/md5"
require "yaml"
require "relaton_bib"
require "relaton/index"
require "relaton_iho/version"
require "relaton_iho/util"
require "relaton_iho/document_type"
require "relaton_iho/iho_bibliography"
require "relaton_iho/hash_converter"
require "relaton_iho/xml_parser"
require "relaton_iho/editorial_group"
require "relaton_iho/iho_group"
require "relaton_iho/comment_periond"
require "relaton_iho/iho_bibliographic_item"

module RelatonIho
  class Error < StandardError; end

  # Returns hash of XML reammar
  # @return [String]
  def self.grammar_hash
    # gem_path = File.expand_path "..", __dir__
    # grammars_path = File.join gem_path, "grammars", "*"
    # grammars = Dir[grammars_path].sort.map { |gp| File.read gp }.join
    Digest::MD5.hexdigest RelatonIho::VERSION + RelatonBib::VERSION # grammars
  end
end

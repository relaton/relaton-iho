module Relaton
  module Iho
    class Doctype < Bib::Doctype
      TYPES = %w[policy-and-procedures best-practices supporting-document
                 report legal directives proposal standard].freeze

      attribute :type, :string, values: TYPES
    end
  end
end

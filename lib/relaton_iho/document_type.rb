module RelatonIho
  class DocumentType < RelatonBib::DocumentType
    DOCTYPES = %w[policy-and-procedures best-practices supporting-document report legal
                  directives proposal standard specification resolution regulation].freeze

    def initialize(type:, abbreviation: nil)
      check_type type
      super
    end

    def check_type(type)
      unless DOCTYPES.include? type
        Util.warn "invalid doctype: `#{type}`"
      end
    end
  end
end

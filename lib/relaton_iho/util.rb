module RelatonIho
  module Util
    extend RelatonBib::Util

    def self.logger
      RelatonIho.configuration.logger
    end
  end
end

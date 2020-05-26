# frozen_string_literal: true

require 'active_support/core_ext/hash'
require 'nokogiri'
require './lib/parsers/base_parser'

class XmlParser
  class << self
    def call(filepath)
      data = extract_data(filepath)
      BaseParser.call(data, filepath)
    end

    private

    def extract_data(filepath)
      content = Nokogiri::XML.parse(File.read(filepath))
                             .remove_namespaces!
                             .to_xml

      Hash.from_xml(content)
    end
  end
end

require 'json'
require './base_parser'

class JsonParser
  class << self
    def call(filepath)
      data = extract_data(filepath)
      BaseParser.call(data, filepath)
    end

    private

    def extract_data(filepath)
      JSON.parse(File.read(filepath))
    end
  end
end

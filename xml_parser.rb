require 'active_support/core_ext/hash'
require 'nokogiri'
require './strategies'

class XmlParser
  def self.call(filepath)
    data = begin
      content = Nokogiri::XML.parse(File.read(filepath)).remove_namespaces!.to_xml
      Hash.from_xml(content)
    end

    strategy = ::Strategies::CLASSES.find { |str| str.responds?(data) }

    [strategy.grades_sum(data), strategy.low_grade_students(data), strategy.total_students(data)]
  end
end

require 'json'
require './strategies'

class JsonParser
  def self.call(filepath)
    data = JSON.parse(File.read(filepath))
    strategy = ::Strategies::CLASSES.find { |str| str.responds?(data) }

    [
      strategy.grades_sum(data),
      strategy.low_grade_students(data),
      strategy.total_students(data)
    ]
  end
end

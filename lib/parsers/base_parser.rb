# frozen_string_literal: true

require './lib/strategies'

class BaseParser
  class << self
    def call(data, filepath)
      strategy = find_startegy(data, filepath)

      [
        strategy.grades_sum(data),
        strategy.low_grade_students(data),
        strategy.total_students(data)
      ]
    end

    private

    def find_startegy(data, filepath)
      ::Strategies::CLASSES.find { |str| str.responds?(data) }.tap do |strategy|
        raise "Unknown file format for #{filepath}" unless strategy
      end
    end
  end
end

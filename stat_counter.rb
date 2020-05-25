require 'active_support/core_ext'
require './json_parser'
require './xml_parser'

class StatCounter
  DATA_FOLDER = 'data'.freeze

  class << self
    def call
      grades, low_grades, total = accumulated_data
      average_grades = Hash[grades.map { |key, value| [key, (value / total).round(1)] }]
      low_grades_percentage = (low_grades / total).round(2) * 100

      puts 'Average Scores:'
      puts "math: #{average_grades[:math]}, russian: #{average_grades[:rus]}, phys: #{average_grades[:phys]}"
      puts "Bad-learning students percentage: #{low_grades_percentage}%"
    end

    private

    def accumulated_data
      grades = { math: 0, rus: 0, phys: 0 }
      low_grades = total = 0

      Dir.each_child(DATA_FOLDER) do |file|
        filepath = "#{DATA_FOLDER}/#{file}"
        result = "#{file.split('.').last}_parser".classify.constantize.call(filepath)

        grades = add_grades(grades, result[0])
        low_grades += result[1]
        total += result[2]
      end

      [grades, low_grades, total.to_f]
    end

    def add_grades(summary, additive)
      summary.tap do |grades|
        grades[:math] += additive[:math]
        grades[:rus] += additive[:rus]
        grades[:phys] += additive[:phys]
      end
    end
  end
end

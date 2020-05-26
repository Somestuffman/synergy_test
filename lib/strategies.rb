# frozen_string_literal: true

require 'dry-schema'

module Strategies
  # Strategy for the first report type (data/school1.json)
  class Type1
    Schema = Dry::Schema.Params do
      required(:name)
      required(:math)
      required(:rus)
      required(:phys)
    end

    def self.responds?(data)
      data.is_a?(Array) && data.reject { |el| Schema.call(el).success? }.empty?
    end

    def self.grades_sum(data)
      data.each_with_object({ math: 0, rus: 0, phys: 0 }) do |value, memo|
        memo[:math] += value['math']
        memo[:rus] += value['rus']
        memo[:phys] += value['phys']
      end
    end

    def self.low_grade_students(data)
      data.select do |el|
        el['math'] <= LOW_GRADE || el['rus'] <= LOW_GRADE || el['phys'] <= LOW_GRADE
      end.size
    end

    def self.total_students(data)
      data.size
    end
  end

  # Strategy for the second report type (data/school2.json)
  class Type2
    VALID_KEYS = %w[mathematics russian_language physics].freeze
    RESULT_KEYS = %i[math rus phys].freeze

    private_constant :VALID_KEYS
    private_constant :RESULT_KEYS

    StudentSchema = Dry::Schema.Params do
      required(:student)
      required(:grade)
    end

    Schema = Dry::Schema.Params do
      required(:mathematics).array(:hash) do
        StudentSchema
      end

      required(:russian_language).array(:hash) do
        StudentSchema
      end

      required(:physics).array(:hash) do
        StudentSchema
      end
    end

    def self.responds?(data)
      data.is_a?(Hash) && data.keys == VALID_KEYS
    end

    def self.grades_sum(data)
      values = VALID_KEYS.map do |key|
        data[key].sum { |el| el['grade'] }
      end

      Hash[RESULT_KEYS.zip(values)]
    end

    def self.low_grade_students(data)
      VALID_KEYS.map do |key|
        data[key].map { |el| el['name'] if el['grade'] <= LOW_GRADE }
      end.flatten.uniq.size
    end

    def self.total_students(data)
      data.values.first.size
    end
  end

  # Strategy for the third report type (data/school3.xml)
  class Type3
    Schema = Dry::Schema.Params do
      required(:root).hash do
        required(:row).array(:hash) do
          required(:name)
          required(:grades).array(:hash) do
            required(:subject)
            required(:score)
          end
        end
      end
    end

    def self.responds?(data)
      Schema.call(data).success?
    end

    def self.grades_sum(data)
      data.dig('root', 'row').map { |el| el['grades'] }
          .flatten
          .each_with_object({ math: 0, rus: 0, phys: 0 }) do |value, memo|
            memo[value['subject'].to_sym] += value['score'].to_i
          end
    end

    def self.low_grade_students(data)
      data.dig('root', 'row').select do |el|
        el['grades'].any? { |grades| grades['score'].to_i <= LOW_GRADE }
      end.size
    end

    def self.total_students(data)
      data.dig('root', 'row').size
    end
  end

  CLASSES = [Type1, Type2, Type3].freeze
  LOW_GRADE = 3
end

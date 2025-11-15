#!/usr/bin/env ruby
# frozen_string_literal: true

# Benchmark script for ahocorasick-rust! 📊
# This generates the benchmark data shown in the README (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧

require 'bundler/setup'
require 'ahocorasick-rust'
require 'benchmark'

# Try to load the pure Ruby ahocorasick gem for comparison
# Install it with: gem install ahocorasick
begin
  require 'ahocorasick'
  PURE_RUBY_AVAILABLE = true
rescue LoadError
  PURE_RUBY_AVAILABLE = false
  puts "⚠️  Pure Ruby 'ahocorasick' gem not found - using fallback implementation"
  puts "   Install it with: gem install ahocorasick"
  puts

  # Simple fallback implementation
  class AhoCorasick
    def initialize(patterns)
      @patterns = patterns
    end

    def lookup(text)
      results = []
      @patterns.each do |pattern|
        pos = 0
        while (idx = text.index(pattern, pos))
          results << pattern
          pos = idx + 1
        end
      end
      results
    end
  end
end

# Naive implementation using each + include?
def naive_lookup(patterns, text)
  patterns.select { |pattern| text.include?(pattern) }
end

# Generate random words for patterns
def generate_words(count, min_length: 3, max_length: 10)
  chars = ('a'..'z').to_a + ('A'..'Z').to_a
  Array.new(count) do
    length = rand(min_length..max_length)
    Array.new(length) { chars.sample }.join
  end
end

# Generate test text with some patterns embedded
def generate_text(target_length, patterns, pattern_density: 0.05)
  words = []
  current_length = 0

  # Common filler words
  filler_words = %w[the a an and or but is are was were be been being have has had
                    having do does did will would could should may might must can
                    in on at by for with from to of about into through during]

  while current_length < target_length
    # Randomly decide whether to insert a pattern or filler
    if rand < pattern_density && patterns.any?
      word = patterns.sample
    else
      word = filler_words.sample
    end

    words << word
    current_length += word.length + 1 # +1 for space
  end

  words.join(' ')
end

# Run a benchmark test
def run_benchmark(setup_name, num_patterns:, num_test_cases:, text_length_range:)
  puts "\n" + "=" * 70
  puts "#{setup_name}"
  puts "=" * 70
  puts "Words: #{num_patterns} patterns"
  puts "Test cases: #{num_test_cases}"
  puts "Text length: #{text_length_range.min} - #{text_length_range.max} chars"
  puts

  # Generate patterns
  patterns = generate_words(num_patterns)

  # Generate test cases
  test_cases = Array.new(num_test_cases) do
    length = rand(text_length_range)
    generate_text(length, patterns)
  end

  # Calculate stats
  avg_length = test_cases.map(&:length).sum / test_cases.size
  max_length = test_cases.map(&:length).max
  min_length = test_cases.map(&:length).min

  puts "Actual text avg length: #{avg_length}"
  puts "Actual text max length: #{max_length}"
  puts "Actual text min length: #{min_length}"
  puts "-" * 70

  # Create matchers
  ruby_matcher = AhoCorasick.new(patterns)
  rust_matcher = AhoCorasickRust.new(patterns)

  # Run benchmarks
  Benchmark.bm(12) do |x|
    x.report('each&include') do
      test_cases.each { |text| naive_lookup(patterns, text) }
    end

    x.report('ruby_ahoc') do
      test_cases.each { |text| ruby_matcher.lookup(text) }
    end

    x.report('rust_ahoc') do
      test_cases.each { |text| rust_matcher.lookup(text) }
    end
  end

  puts
end

# Main benchmark runner
puts "🌈 Aho-Corasick Benchmark Suite ✨"
puts "Comparing performance across different implementations!"
puts

# Test Setup 1 - Smaller texts
run_benchmark(
  'Test Setup 1: Medium-sized texts',
  num_patterns: 500,
  num_test_cases: 2000,
  text_length_range: (500..25_000)
)

# Test Setup 2 - Larger texts with more variation
run_benchmark(
  'Test Setup 2: Large texts with high variation',
  num_patterns: 500,
  num_test_cases: 2000,
  text_length_range: (1000..10_500_000)
)

# Test Setup 3 - Quick test with smaller dataset
run_benchmark(
  'Test Setup 3: Quick test (small dataset)',
  num_patterns: 100,
  num_test_cases: 500,
  text_length_range: (100..5000)
)

puts "\n✨ Benchmark complete! (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧"
puts
if PURE_RUBY_AVAILABLE
  puts "Note: The 'rust_ahoc' implementation (this gem) is significantly faster"
  puts "than both the naive 'each&include' and pure Ruby 'ahocorasick' gem!"
else
  puts "Note: For accurate comparison, install the pure Ruby version:"
  puts "  gem install ahocorasick"
end
puts "The larger the text and more patterns you have, the bigger the speedup! 🚀"

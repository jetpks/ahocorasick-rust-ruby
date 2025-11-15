# frozen_string_literal: true

require 'test/unit'
require_relative '../lib/ahocorasick-rust'

class RahocorasickTest < Test::Unit::TestCase
  # Constructor tests - happy paths
  def test_new_with_array_of_strings
    matcher = AhoCorasickRust.new(%w[foo bar])
    assert_not_nil matcher
  end

  def test_new_with_empty_array
    matcher = AhoCorasickRust.new([])
    assert_not_nil matcher
  end

  def test_new_with_single_pattern
    matcher = AhoCorasickRust.new(['hello'])
    assert_not_nil matcher
  end

  def test_new_with_duplicate_patterns
    matcher = AhoCorasickRust.new(%w[foo bar foo])
    assert_not_nil matcher
  end

  # Constructor tests - error cases
  def test_new_with_nil_raises_error
    assert_raise(TypeError) { AhoCorasickRust.new(nil) }
  end

  def test_new_with_non_array_raises_error
    assert_raise(TypeError) { AhoCorasickRust.new('not an array') }
  end

  def test_new_with_array_containing_non_strings_raises_error
    assert_raise(TypeError) { AhoCorasickRust.new(['foo', 123, 'bar']) }
  end

  def test_new_with_array_containing_nil_raises_error
    assert_raise(TypeError) { AhoCorasickRust.new(['foo', nil, 'bar']) }
  end

  # Lookup tests - basic functionality
  def test_lookup_finds_patterns
    matcher = AhoCorasickRust.new(%w[foo bar])
    result = matcher.lookup('Hello foolish bar.')
    assert_equal(%w[foo bar], result)
  end

  def test_lookup_returns_matches_in_order_found
    matcher = AhoCorasickRust.new(%w[foo bar])
    result = matcher.lookup("I went to the bar to see if they served foo,\n\t but they didn't.")
    assert_equal(%w[bar foo], result)
  end

  def test_lookup_with_unicode
    matcher = AhoCorasickRust.new(%w[数据 金数据])
    result = matcher.lookup('金数据，人人可用的业务数据收集工具')
    assert_equal(%w[金数据 数据], result)
  end

  def test_lookup_with_emoji
    matcher = AhoCorasickRust.new(['😊', '🎉', '😢'])
    result = matcher.lookup('I am 😊 and 🎉 today!')
    assert_equal(['😊', '🎉'], result)
  end

  # Lookup tests - edge cases
  def test_lookup_with_empty_haystack
    matcher = AhoCorasickRust.new(%w[foo bar])
    result = matcher.lookup('')
    assert_equal([], result)
  end

  def test_lookup_with_no_matches
    matcher = AhoCorasickRust.new(%w[foo bar])
    result = matcher.lookup('hello world')
    assert_equal([], result)
  end

  def test_lookup_with_empty_patterns
    matcher = AhoCorasickRust.new([])
    result = matcher.lookup('hello world')
    assert_equal([], result)
  end

  def test_lookup_with_overlapping_patterns
    matcher = AhoCorasickRust.new(%w[abc bcd])
    result = matcher.lookup('abcd')
    # Uses leftmost-first matching - finds 'abc' first, then continues from position 3
    assert_equal(%w[abc], result)
  end

  def test_lookup_with_non_overlapping_occurrences
    matcher = AhoCorasickRust.new(%w[abc bcd])
    result = matcher.lookup('abc bcd')
    # Both patterns appear separately, should find both
    assert_equal(%w[abc bcd], result)
  end

  def test_lookup_with_duplicate_matches
    matcher = AhoCorasickRust.new(%w[foo])
    result = matcher.lookup('foo foo foo')
    # Should find 'foo' three times
    assert_equal(%w[foo foo foo], result)
  end

  def test_lookup_case_sensitive
    matcher = AhoCorasickRust.new(['Ruby'])
    result = matcher.lookup('I love ruby and RUBY')
    # Should not match 'ruby' or 'RUBY', only exact case 'Ruby'
    assert_equal([], result)
  end

  def test_lookup_case_sensitive_matches_exact_case
    matcher = AhoCorasickRust.new(['Ruby', 'ruby', 'RUBY'])
    result = matcher.lookup('I love Ruby, ruby is great, and RUBY rocks!')
    assert_equal(['Ruby', 'ruby', 'RUBY'], result)
  end

  def test_lookup_with_whitespace_patterns
    matcher = AhoCorasickRust.new(['hello world', 'foo bar'])
    result = matcher.lookup('Say hello world and foo bar!')
    assert_equal(['hello world', 'foo bar'], result)
  end

  def test_lookup_with_special_characters
    matcher = AhoCorasickRust.new(['c++', 'c#', 'f#'])
    result = matcher.lookup('I code in c++ and c# but not f#')
    assert_equal(['c++', 'c#', 'f#'], result)
  end

  # Lookup tests - error cases
  def test_lookup_with_nil_haystack_raises_error
    matcher = AhoCorasickRust.new(%w[foo bar])
    assert_raise(TypeError) { matcher.lookup(nil) }
  end

  def test_lookup_with_non_string_haystack_raises_error
    matcher = AhoCorasickRust.new(%w[foo bar])
    assert_raise(TypeError) { matcher.lookup(123) }
  end

  def test_lookup_with_array_haystack_raises_error
    matcher = AhoCorasickRust.new(%w[foo bar])
    assert_raise(TypeError) { matcher.lookup(['hello', 'world']) }
  end
end

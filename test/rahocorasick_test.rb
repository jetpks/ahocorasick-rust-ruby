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

  # match? tests
  def test_match_returns_true_when_pattern_found
    matcher = AhoCorasickRust.new(%w[foo bar])
    assert_true(matcher.match?('hello foo world'))
  end

  def test_match_returns_false_when_no_pattern_found
    matcher = AhoCorasickRust.new(%w[foo bar])
    assert_false(matcher.match?('hello world'))
  end

  def test_match_returns_true_for_multiple_patterns
    matcher = AhoCorasickRust.new(%w[foo bar baz])
    assert_true(matcher.match?('foo and bar'))
  end

  def test_match_returns_false_for_empty_haystack
    matcher = AhoCorasickRust.new(%w[foo bar])
    assert_false(matcher.match?(''))
  end

  def test_match_returns_false_with_empty_patterns
    matcher = AhoCorasickRust.new([])
    assert_false(matcher.match?('hello world'))
  end

  def test_match_works_with_unicode
    matcher = AhoCorasickRust.new(['数据'])
    assert_true(matcher.match?('金数据工具'))
    assert_false(matcher.match?('hello world'))
  end

  def test_match_case_sensitive
    matcher = AhoCorasickRust.new(['Ruby'])
    assert_false(matcher.match?('I love ruby'))
    assert_true(matcher.match?('I love Ruby'))
  end

  def test_match_case_insensitive
    matcher = AhoCorasickRust.new(['Ruby'], case_insensitive: true)
    assert_true(matcher.match?('I love ruby'))
    assert_true(matcher.match?('I love RUBY'))
    assert_true(matcher.match?('I love Ruby'))
  end

  def test_match_with_nil_haystack_raises_error
    matcher = AhoCorasickRust.new(%w[foo bar])
    assert_raise(TypeError) { matcher.match?(nil) }
  end

  def test_match_with_non_string_haystack_raises_error
    matcher = AhoCorasickRust.new(%w[foo bar])
    assert_raise(TypeError) { matcher.match?(123) }
  end

  # lookup_with_positions tests
  def test_lookup_with_positions_returns_pattern_and_offsets
    matcher = AhoCorasickRust.new(%w[fox dog])
    text = 'The quick brown fox jumps over the lazy dog.'
    result = matcher.lookup_with_positions(text)

    assert_equal(2, result.length)
    assert_equal({ pattern: 'fox', start: 16, end: 19 }, result[0])
    assert_equal({ pattern: 'dog', start: 40, end: 43 }, result[1])
  end

  def test_lookup_with_positions_with_no_matches
    matcher = AhoCorasickRust.new(%w[foo bar])
    result = matcher.lookup_with_positions('hello world')
    assert_equal([], result)
  end

  def test_lookup_with_positions_with_multiple_occurrences
    matcher = AhoCorasickRust.new(['test'])
    result = matcher.lookup_with_positions('test this test')

    assert_equal(2, result.length)
    assert_equal({ pattern: 'test', start: 0, end: 4 }, result[0])
    assert_equal({ pattern: 'test', start: 10, end: 14 }, result[1])
  end

  def test_lookup_with_positions_with_unicode
    matcher = AhoCorasickRust.new(%w[数据])
    result = matcher.lookup_with_positions('金数据工具')

    assert_equal(1, result.length)
    # Note: offsets are in bytes, not characters
    assert_equal('数据', result[0][:pattern])
    assert(result[0][:start] > 0)
    assert(result[0][:end] > result[0][:start])
  end

  # Case-insensitive matching tests
  def test_case_insensitive_matching
    matcher = AhoCorasickRust.new(['Ruby'], case_insensitive: true)
    result = matcher.lookup('I love ruby and RUBY')
    assert_equal(['Ruby', 'Ruby'], result)
  end

  def test_case_insensitive_with_multiple_patterns
    matcher = AhoCorasickRust.new(%w[foo BAR], case_insensitive: true)
    result = matcher.lookup('FOO and bar and Foo')
    assert_equal(['foo', 'BAR', 'foo'], result)
  end

  def test_case_insensitive_false_still_case_sensitive
    matcher = AhoCorasickRust.new(['Ruby'], case_insensitive: false)
    result = matcher.lookup('I love ruby and RUBY')
    assert_equal([], result)
  end

  def test_case_sensitive_is_default
    matcher1 = AhoCorasickRust.new(['Ruby'])
    matcher2 = AhoCorasickRust.new(['Ruby'], case_insensitive: false)

    text = 'I love ruby and RUBY'
    assert_equal(matcher1.lookup(text), matcher2.lookup(text))
  end

  # replace_all tests - with hash
  def test_replace_all_with_hash
    matcher = AhoCorasickRust.new(%w[foo bar])
    text = 'foo and bar are here'
    result = matcher.replace_all(text, { 'foo' => 'FOO', 'bar' => 'BAR' })
    assert_equal('FOO and BAR are here', result)
  end

  def test_replace_all_with_partial_hash
    matcher = AhoCorasickRust.new(%w[foo bar baz])
    text = 'foo bar baz'
    result = matcher.replace_all(text, { 'foo' => 'FOO' })
    # Only foo is replaced, bar and baz stay the same
    assert_equal('FOO bar baz', result)
  end

  def test_replace_all_with_empty_hash
    matcher = AhoCorasickRust.new(%w[foo bar])
    text = 'foo and bar'
    result = matcher.replace_all(text, {})
    # Nothing is replaced
    assert_equal('foo and bar', result)
  end

  def test_replace_all_preserves_non_matched_text
    matcher = AhoCorasickRust.new(['world'])
    text = 'Hello, world! How are you?'
    result = matcher.replace_all(text, { 'world' => 'Ruby' })
    assert_equal('Hello, Ruby! How are you?', result)
  end

  # replace_all tests - with block
  def test_replace_all_with_block
    matcher = AhoCorasickRust.new(%w[foo bar])
    text = 'foo and bar'
    result = matcher.replace_all(text) { |match| match.upcase }
    assert_equal('FOO and BAR', result)
  end

  def test_replace_all_with_block_custom_logic
    matcher = AhoCorasickRust.new(%w[apple banana cherry])
    text = 'I like apple, banana, and cherry'
    result = matcher.replace_all(text) do |fruit|
      { 'apple' => '🍎', 'banana' => '🍌', 'cherry' => '🍒' }[fruit]
    end
    assert_equal('I like 🍎, 🍌, and 🍒', result)
  end

  def test_replace_all_with_block_different_lengths
    matcher = AhoCorasickRust.new(['a', 'bb'])
    text = 'a bb a bb'
    result = matcher.replace_all(text) { |match| match.length.to_s }
    assert_equal('1 2 1 2', result)
  end

  def test_replace_all_with_no_matches
    matcher = AhoCorasickRust.new(%w[foo bar])
    text = 'hello world'
    result = matcher.replace_all(text, { 'foo' => 'FOO' })
    assert_equal('hello world', result)
  end

  # Combined features tests
  def test_case_insensitive_lookup_with_positions
    matcher = AhoCorasickRust.new(['ruby'], case_insensitive: true)
    text = 'Ruby is great and RUBY rocks'
    result = matcher.lookup_with_positions(text)

    assert_equal(2, result.length)
    assert_equal({ pattern: 'ruby', start: 0, end: 4 }, result[0])
    assert_equal({ pattern: 'ruby', start: 18, end: 22 }, result[1])
  end

  def test_case_insensitive_replace_all
    matcher = AhoCorasickRust.new(['ruby'], case_insensitive: true)
    text = 'I love Ruby and RUBY'
    result = matcher.replace_all(text, { 'ruby' => 'Python' })
    assert_equal('I love Python and Python', result)
  end
end

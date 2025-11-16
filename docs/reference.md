# API Reference

Complete reference for all methods and options in the `ahocorasick-rust` gem.

## Table of Contents

- [Constructor](#constructor)
- [Search Methods](#search-methods)
- [Replace Methods](#replace-methods)

---

## Constructor

### `AhoCorasickRust.new(patterns, **options)`

Creates a new Aho-Corasick matcher from an array of pattern strings.

**Parameters:**
- `patterns` (Array<String>) - Array of pattern strings to search for
- `options` (Hash) - Optional configuration

**Options:**
- `case_insensitive` (Boolean) - Enable ASCII case-insensitive matching (default: `false`)
- `match_kind` (Symbol) - Strategy for handling overlapping patterns (default: `:leftmost_first`)
  - `:leftmost_first` - First pattern in list wins
  - `:leftmost_longest` - Longest pattern wins
  - `:standard` - Standard Aho-Corasick behavior

**Examples:**

```ruby
# Basic usage
matcher = AhoCorasickRust.new(['foo', 'bar', 'baz'])

# Case-insensitive matching
matcher = AhoCorasickRust.new(['Ruby', 'Python'], case_insensitive: true)

# Control match priority
matcher = AhoCorasickRust.new(['abc', 'abcd'], match_kind: :leftmost_longest)

# Combine options
matcher = AhoCorasickRust.new(
  ['test', 'testing'],
  case_insensitive: true,
  match_kind: :leftmost_longest
)
```

**Raises:**
- `TypeError` - If patterns is not an array or contains non-strings
- `ArgumentError` - If match_kind is invalid
- `RuntimeError` - If automaton construction fails

---

## Search Methods

### `#lookup(haystack)`

Finds all non-overlapping pattern matches in the haystack.

**Parameters:**
- `haystack` (String) - The text to search

**Returns:** Array<String> - Array of matched patterns

**Examples:**

```ruby
matcher = AhoCorasickRust.new(['foo', 'bar'])

matcher.lookup('foo and bar')
# => ['foo', 'bar']

matcher.lookup('hello world')
# => []

# Non-overlapping: finds 'abc' and stops
matcher = AhoCorasickRust.new(['abc', 'bcd'])
matcher.lookup('abcd')
# => ['abc']
```

---

### `#lookup_overlapping(haystack)`

Finds all pattern matches, including overlapping ones.

**Parameters:**
- `haystack` (String) - The text to search

**Returns:** Array<String> - Array of all matched patterns, including overlaps

**Examples:**

```ruby
matcher = AhoCorasickRust.new(['abc', 'bcd', 'cde'])

matcher.lookup_overlapping('abcde')
# => ['abc', 'bcd', 'cde']

# Compare with non-overlapping
matcher.lookup('abcde')
# => ['abc']

# Finds multiple occurrences of same pattern at different positions
matcher = AhoCorasickRust.new(['a', 'ab'])
matcher.lookup_overlapping('aab')
# => ['a', 'a', 'ab']
```

---

### `#lookup_with_positions(haystack)`

Finds all non-overlapping matches with their byte positions.

**Parameters:**
- `haystack` (String) - The text to search

**Returns:** Array<Hash> - Array of hashes with `:pattern`, `:start`, `:end` keys

**Examples:**

```ruby
matcher = AhoCorasickRust.new(['fox', 'dog'])

matcher.lookup_with_positions('The quick brown fox jumps over the lazy dog.')
# => [
#      { pattern: 'fox', start: 16, end: 19 },
#      { pattern: 'dog', start: 40, end: 43 }
#    ]

matcher.lookup_with_positions('hello world')
# => []

# Positions are byte offsets, not character offsets
matcher = AhoCorasickRust.new(['数据'])
matcher.lookup_with_positions('金数据工具')
# => [{ pattern: '数据', start: 3, end: 9 }]  # byte positions
```

---

### `#match?(haystack)`

Checks if any pattern matches in the haystack (predicate method).

**Parameters:**
- `haystack` (String) - The text to search

**Returns:** Boolean - `true` if any pattern matches, `false` otherwise

**Examples:**

```ruby
matcher = AhoCorasickRust.new(['foo', 'bar'])

matcher.match?('hello foo world')
# => true

matcher.match?('hello world')
# => false

# Works with case-insensitive
matcher = AhoCorasickRust.new(['Ruby'], case_insensitive: true)
matcher.match?('I love ruby')
# => true
```

---

### `#find_first(haystack)`

Returns the first pattern match found, or `nil` if no match.

**Parameters:**
- `haystack` (String) - The text to search

**Returns:** String or nil - First matched pattern, or `nil` if no match

**Examples:**

```ruby
matcher = AhoCorasickRust.new(['foo', 'bar', 'baz'])

matcher.find_first('hello foo bar baz')
# => 'foo'

matcher.find_first('hello world')
# => nil

# Stops after first match (more efficient than #lookup)
matcher = AhoCorasickRust.new(['cat', 'dog', 'bird'])
matcher.find_first('The cat and dog are friends')
# => 'cat'  (stops, doesn't find 'dog')
```

---

### `#find_first_with_position(haystack)`

Returns the first pattern match with its position, or `nil` if no match.

**Parameters:**
- `haystack` (String) - The text to search

**Returns:** Hash or nil - Hash with `:pattern`, `:start`, `:end` keys, or `nil` if no match

**Examples:**

```ruby
matcher = AhoCorasickRust.new(['foo', 'bar'])

matcher.find_first_with_position('hello foo world')
# => { pattern: 'foo', start: 6, end: 9 }

matcher.find_first_with_position('hello world')
# => nil

# Finds earliest match in text, not first in pattern list
matcher = AhoCorasickRust.new(['bar', 'foo'])
matcher.find_first_with_position('foo bar baz')
# => { pattern: 'foo', start: 0, end: 3 }  # 'foo' appears first in text
```

---

## Replace Methods

### `#replace_all(haystack, replacements)`

Replaces all pattern matches with their corresponding replacements.

**Parameters:**
- `haystack` (String) - The text to search
- `replacements` (Hash or Block) - Replacement mapping or block

**Returns:** String - New string with replacements applied

**Hash-based replacement:**

Maps pattern strings to their replacements. Patterns not in the hash remain unchanged.

```ruby
matcher = AhoCorasickRust.new(['foo', 'bar', 'baz'])

matcher.replace_all('foo and bar', { 'foo' => 'FOO', 'bar' => 'BAR' })
# => 'FOO and BAR'

# Partial replacement - 'baz' not in hash, stays unchanged
matcher.replace_all('foo bar baz', { 'foo' => 'hello' })
# => 'hello bar baz'

# Empty hash - no replacements
matcher.replace_all('foo and bar', {})
# => 'foo and bar'
```

**Block-based replacement:**

Passes each matched pattern to the block, uses return value as replacement.

```ruby
matcher = AhoCorasickRust.new(['foo', 'bar'])

matcher.replace_all('foo and bar') { |match| match.upcase }
# => 'FOO and BAR'

# Dynamic replacement logic
matcher = AhoCorasickRust.new(['apple', 'banana', 'cherry'])
text = 'I like apple, banana, and cherry'
result = matcher.replace_all(text) do |fruit|
  { 'apple' => '🍎', 'banana' => '🍌', 'cherry' => '🍒' }[fruit]
end
# => 'I like 🍎, 🍌, and 🍒'

# Replacement length can differ from match
matcher = AhoCorasickRust.new(['a', 'bb'])
matcher.replace_all('a bb a bb') { |m| m.length.to_s }
# => '1 2 1 2'
```

**Raises:**
- `ArgumentError` - If replacements is neither a Hash nor a block given

---

## Usage Patterns

### Content Filtering

```ruby
# Filter profanity with asterisks
bad_words = ['bad', 'worse', 'worst']
filter = AhoCorasickRust.new(bad_words, case_insensitive: true)

filter.replace_all('This is bad and worse') { |word| '*' * word.length }
# => 'This is *** and *****'
```

### Keyword Highlighting

```ruby
keywords = ['Ruby', 'Python', 'JavaScript']
matcher = AhoCorasickRust.new(keywords)

positions = matcher.lookup_with_positions('I love Ruby and Python')
# Use positions to add HTML tags, syntax highlighting, etc.
```

### Quick Existence Check

```ruby
# Check if any banned word appears
banned = ['spam', 'scam', 'fraud']
checker = AhoCorasickRust.new(banned, case_insensitive: true)

if checker.match?(user_input)
  reject_message
end
```

### DNA Sequence Analysis

```ruby
# Find all overlapping genetic markers
markers = ['ATCG', 'TCGA', 'CGAT']
analyzer = AhoCorasickRust.new(markers)

sequence = 'ATCGAT'
analyzer.lookup_overlapping(sequence)
# => ['ATCG', 'TCGA', 'CGAT']  # all overlapping matches
```

### Tokenization

```ruby
# Prefer longest matches for tokens
keywords = ['if', 'iffy', 'then', 'end', 'endif']
tokenizer = AhoCorasickRust.new(keywords, match_kind: :leftmost_longest)

tokenizer.lookup('iffy then endif')
# => ['iffy', 'then', 'endif']  # chooses longer 'iffy' over 'if'
```

---

## Type Compatibility

### Accepted Types

- **Patterns:** Array of String objects
- **Haystack:** String objects
- **Options:** Symbol keys (`:case_insensitive`, `:match_kind`)
- **Replacements:** Hash with String keys/values, or Block returning String

### Unicode Support

All methods support UTF-8 encoded strings:

```ruby
matcher = AhoCorasickRust.new(['こんにちは', '世界'])
matcher.lookup('こんにちは世界')
# => ['こんにちは', '世界']

# Emoji support
matcher = AhoCorasickRust.new(['😊', '🎉'])
matcher.lookup('I am 😊 today 🎉')
# => ['😊', '🎉']
```

**Note:** Position values in `#lookup_with_positions` and `#find_first_with_position` are byte offsets, not character offsets. For multi-byte UTF-8 characters, byte positions will differ from character positions.

---

## Error Handling

```ruby
# TypeError: patterns must be array of strings
AhoCorasickRust.new('not an array')
# TypeError: wrong argument type String (expected Array)

AhoCorasickRust.new(['foo', 123])
# TypeError: wrong argument type Integer (expected String)

# ArgumentError: invalid match_kind
AhoCorasickRust.new(['foo'], match_kind: :invalid)
# ArgumentError: Invalid match_kind: 'invalid'...

# TypeError: haystack must be string
matcher.lookup(123)
# TypeError: wrong argument type Integer (expected String)
```

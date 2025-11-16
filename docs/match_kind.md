# Match Kind Strategies

The `match_kind` option controls how the Aho-Corasick automaton behaves when multiple patterns could match at the same position in the text. This is important when you have overlapping patterns like `'abc'` and `'abcd'`.

## Available Options

### `:leftmost_first` (default)

**Priority:** First pattern in the list wins

When multiple patterns could match at the same position, the pattern that appears first in your pattern list takes precedence.

```ruby
matcher = AhoCorasickRust.new(['abc', 'abcd'], match_kind: :leftmost_first)
matcher.lookup('abcd')
# => ['abc']  # 'abc' appears first in the pattern list, so it wins
```

**Use cases:**
- Keyword replacement where you want specific patterns to take precedence
- Content filtering with priority rules
- When you want explicit control over match priority by ordering your patterns

---

### `:leftmost_longest`

**Priority:** Longest match wins

When multiple patterns could match at the same position, the longest matching pattern is preferred.

```ruby
matcher = AhoCorasickRust.new(['abc', 'abcd'], match_kind: :leftmost_longest)
matcher.lookup('abcd')
# => ['abcd']  # 'abcd' is longer, so it wins
```

**Use cases:**
- Tokenization where longer tokens are more meaningful
- Entity recognition where you want the most specific match
- Parsing structured text where longer patterns indicate more context

---

### `:standard`

**Priority:** Standard Aho-Corasick algorithm behavior

Reports matches as they're encountered in the automaton's state machine. This is the classical Aho-Corasick behavior.

```ruby
matcher = AhoCorasickRust.new(['abc', 'abcd'], match_kind: :standard)
matcher.lookup('abcd')
# => ['abc']  # Reports matches as the automaton finds them
```

**Use cases:**
- When you need strict Aho-Corasick semantics
- Potentially slightly faster for certain pattern sets
- Academic or research purposes requiring standard algorithm behavior

## Comparison Example

Given patterns `['ab', 'abc', 'abcd']` and text `'abcd'`:

| match_kind | Result | Reason |
|------------|--------|--------|
| `:leftmost_first` | `['ab']` | First pattern in list |
| `:leftmost_longest` | `['abcd']` | Longest matching pattern |
| `:standard` | `['ab']` | First match encountered by automaton |

## Interaction with Other Features

### With `#lookup_overlapping`

The `match_kind` option does **not** affect `#lookup_overlapping`, which always returns all overlapping matches regardless of the strategy:

```ruby
matcher = AhoCorasickRust.new(['abc', 'bcd'], match_kind: :leftmost_first)

# match_kind affects non-overlapping lookup
matcher.lookup('abcd')
# => ['abc']  (only one match, respects match_kind)

# overlapping lookup ignores match_kind
matcher.lookup_overlapping('abcd')
# => ['abc', 'bcd']  (all matches, ignores match_kind)
```

### With `case_insensitive`

The `match_kind` and `case_insensitive` options work together seamlessly:

```ruby
matcher = AhoCorasickRust.new(
  ['abc', 'abcd'],
  match_kind: :leftmost_longest,
  case_insensitive: true
)
matcher.lookup('ABCD')
# => ['abcd']  # Finds longest match, case-insensitively
```

### With `#find_first`

The `match_kind` affects which match is returned by `#find_first`:

```ruby
# With leftmost_first
matcher1 = AhoCorasickRust.new(['abc', 'abcd'], match_kind: :leftmost_first)
matcher1.find_first('abcd')  # => 'abc'

# With leftmost_longest
matcher2 = AhoCorasickRust.new(['abc', 'abcd'], match_kind: :leftmost_longest)
matcher2.find_first('abcd')  # => 'abcd'
```

## Choosing the Right Strategy

**Use `:leftmost_first` when:**
- You want explicit control over priority
- Pattern order is meaningful in your domain
- You're doing rule-based text processing

**Use `:leftmost_longest` when:**
- Longer matches are more specific/important
- You're tokenizing or parsing
- You want the most complete match

**Use `:standard` when:**
- You need classical Aho-Corasick semantics
- You're comparing against other implementations
- Performance is critical and you understand the tradeoffs

## Performance Notes

All three strategies use the same underlying automaton construction, so performance differences are minimal. The main difference is in the matching logic when choosing between multiple possible matches at the same position.

In practice, `:leftmost_first` (the default) provides the best balance of performance, predictability, and control for most use cases.

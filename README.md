# Aho-Corasick Rust ✨

[![Gem Version](https://badge.fury.io/rb/ahocorasick-rust.svg)](https://badge.fury.io/rb/ahocorasick-rust)

> **Blazing-fast multi-pattern string matching for Ruby!** (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧

`ahocorasick-rust` is a Ruby wrapper for the [Aho-Corasick algorithm](https://github.com/BurntSushi/aho-corasick) implemented in Rust! 🦀💎

## What is Aho-Corasick? 🤔

Aho-Corasick is a powerful string searching algorithm that can find **multiple patterns simultaneously** in a single pass through your text! Unlike traditional string matching that searches for one pattern at a time, Aho-Corasick builds a finite state machine from your dictionary of patterns and matches them all at once.

**Perfect for:**
- 🔍 Content filtering & moderation
- 📝 Finding keywords in large documents
- 🚫 Detecting prohibited words or phrases
- 🏷️ Multi-pattern text analysis
- ⚡ Any scenario where you need to search for many patterns efficiently!

**Why this gem rocks:**
- 🦀 Powered by Rust for maximum speed
- 💎 Easy Ruby interface
- 🚀 Up to **67x faster** than pure Ruby implementations
- ✨ Precompiled binaries for major platforms
- 🌈 Works with Ruby 2.7+

## Installation 📦

Add this gem to your `Gemfile`:

```ruby
gem 'ahocorasick-rust'
```

Then execute:

```bash
bundle install
```

Or install it yourself:

```bash
gem install ahocorasick-rust
```

## Usage 🎀

It's super simple!

```ruby
require 'ahocorasick-rust'

# Create a new matcher with your patterns
animals = ['cat', 'dog', 'bunny', 'fox']
matcher = AhoCorasickRust.new(animals)

# Search for all patterns in your text - finds them all in one pass! ✨
text = "The quick brown fox jumps over the lazy dog."
matcher.lookup(text)
# => ["fox", "dog"]
```

**Want more examples?** Check out our [example script](scripts/example.rb) with content filtering, language detection, and more! 🌈

## Benchmark 📊

**Don't just take our word for it - check out these performance numbers!** 🎉

### Test Setup 1
- Words: 500 patterns
- Test cases: 2,000
- Text length: 3,154 chars (avg), 23,676 (max)

```
       user     system      total        real
each&include  6.487059   0.185424   6.672483 (  6.791808)
ruby_ahoc     4.178672   0.138610   4.317282 (  4.547964)
rust_ahoc     0.157662   0.004847   0.162509 (  0.166964)
```

> 🎈 **27.2x faster** than pure Ruby implementation!

### Test Setup 2
- Words: 500 patterns
- Test cases: 2,000
- Text length: 49,162 chars (avg), 10,392,056 (max)

```
       user     system      total        real
each&include 27.903179   0.237389  28.140568 ( 28.563194)
ruby_ahoc    45.220535   0.363107  45.583642 ( 46.477702)
rust_ahoc     0.670583   0.007192   0.677775 (  0.686904)
```

> 🎈 **67.7x faster** than pure Ruby implementation!

The larger your text and the more patterns you have, the more this gem shines! ✨

## Platform Support 🌍

Precompiled binaries are available for:
- 🍎 macOS (ARM64 & x86_64)
- 🐧 Linux (ARM64 & x86_64)

If a precompiled binary isn't available for your platform, the gem will automatically compile the Rust extension during installation.

## Development 🛠️

Want to contribute? Yay! 🎉

```bash
# Install dependencies
bundle install

# Compile the extension
fish -c "bundle exec rake dev compile"

# Run tests
fish -c "bundle exec rake test"

# Build the gem
gem build ahocorasick-rust.gemspec
```

## References 📚

- [Aho-Corasick (Rust)](https://github.com/BurntSushi/aho-corasick) - The amazing Rust implementation we wrap
- [Aho-Corasick Algorithm](https://en.wikipedia.org/wiki/Aho%E2%80%93Corasick_algorithm) - Learn about the algorithm
- [Original Ruby Implementation](https://github.com/ahnick/ahocorasick) - Pure Ruby version for comparison

## Contributing 💝

Bug reports and pull requests are welcome on GitHub at [https://github.com/jetpks/ahocorasick-rust-ruby](https://github.com/jetpks/ahocorasick-rust-ruby)!

## License 📄

This gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

---

Made with 💖 and Rust 🦀 by Eric

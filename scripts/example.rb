#!/usr/bin/env ruby
# frozen_string_literal: true

# Example script for ahocorasick-rust! ✨
# This demonstrates the super fast multi-pattern matching powers! (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧

require 'bundler/setup'
require 'ahocorasick-rust'

puts "🌈 Welcome to Aho-Corasick Rust Example! ✨\n\n"

# Example 1: Finding animals! 💖
puts "Example 1: Finding animals in text 🐱🐶🐰"
puts "=" * 50

animals = ['cat', 'dog', 'bunny', 'fox', 'otter']
matcher = AhoCorasickRust.new(animals)

text1 = "The quick brown fox jumps over the lazy dog. A cat and bunny watch nearby."
matches1 = matcher.lookup(text1)

puts "Text: #{text1}"
puts "Patterns: #{animals.inspect}"
puts "✨ Found: #{matches1.inspect}"
puts

# Example 2: Content moderation 🚫
puts "Example 2: Content filtering 🛡️"
puts "=" * 50

banned_words = ['spam', 'scam', 'phishing', 'malware']
moderator = AhoCorasickRust.new(banned_words)

text2 = "This is a totally legitimate email, not spam or a phishing attempt!"
matches2 = moderator.lookup(text2)

puts "Text: #{text2}"
puts "Banned words: #{banned_words.inspect}"
puts "⚠️  Flagged: #{matches2.inspect}"
puts

# Example 3: Finding programming languages 💻
puts "Example 3: Detecting programming languages 🚀"
puts "=" * 50

languages = ['Ruby', 'Python', 'JavaScript', 'Rust', 'Go']
lang_matcher = AhoCorasickRust.new(languages)

text3 = "I love writing Ruby with a Rust backend! Python and JavaScript are cool too."
matches3 = lang_matcher.lookup(text3)

puts "Text: #{text3}"
puts "Languages: #{languages.inspect}"
puts "🔍 Detected: #{matches3.inspect}"
puts

# Example 4: Finding actual emojis! ⚡
puts "Example 4: Matching actual emoji characters ✨"
puts "=" * 50

# Create a matcher with actual emoji characters!
emojis = ['😊', '😢', '🎉', '😴', '🍕', '☕', '😠', '🌸']
emoji_matcher = AhoCorasickRust.new(emojis)

# Generate some text with emojis
big_text = "I was so 🎉 this morning, but now I'm really 😴 and need 🍕. " \
           "Yesterday I was 😊 and 🌸, but today I feel a bit 😠 and 😢. " \
           "I think I just need ☕ to feel better!"

matches4 = emoji_matcher.lookup(big_text)

puts "Text: #{big_text}"
puts "Dictionary size: #{emojis.length} emoji patterns"
puts "✨ Found emojis: #{matches4.inspect}"
puts

# Example 5: Case sensitivity demonstration 🔤
puts "Example 5: Case sensitivity matters! 🔤"
puts "=" * 50

case_patterns = ['Ruby', 'ruby', 'RUBY']
case_matcher = AhoCorasickRust.new(case_patterns)

text5 = "I love Ruby, ruby is great, and RUBY rocks!"
matches5 = case_matcher.lookup(text5)

puts "Text: #{text5}"
puts "Patterns: #{case_patterns.inspect}"
puts "📝 Matches: #{matches5.inspect}"
puts "Note: Each case variant is treated as a separate pattern!"
puts

puts "\n✨ All examples complete! Aho-Corasick is super fast! (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧"

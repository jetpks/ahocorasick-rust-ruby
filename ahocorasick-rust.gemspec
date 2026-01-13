# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)

Gem::Specification.new do |s|
  s.name = 'ahocorasick-rust'
  s.version = '2.2.0'
  s.platform = Gem::Platform::RUBY
  s.authors = ['Eric']
  s.email = ['eric@ebj.dev']
  s.homepage = 'https://github.com/jetpks/ahocorasick-rust-ruby'
  s.summary = 'Blazing-fast ✨ Ruby wrapper for the Rust Aho-Corasick string matching algorithm!'
  s.description = 'A Ruby gem wrapping the legendary Rust Aho-Corasick algorithm! ' \
                  'Aho-Corasick is a powerful string searching algorithm that finds multiple patterns ' \
                  'simultaneously in a text. Features include overlapping matches, case-insensitive search, ' \
                  'find & replace, match positions, and configurable match strategies. ' \
                  'Perfect for content filtering, tokenization, and multi-pattern search at lightning speed! (ﾉ◕ヮ◕)ﾉ*:･ﾟ✧'
  s.files = Dir['lib/**/*.rb', 'ext/**/*.{rs,toml,lock,rb}', 'docs/**/*.md'] + %w[README.md Rakefile]
  s.require_paths = ['lib']
  s.license = 'MIT'
  s.extensions = ['ext/rahocorasick/extconf.rb']
  s.required_ruby_version = '>= 2.7.0'

  # needed until rubygems supports Rust support is out of beta
  s.add_dependency 'rb_sys', '~> 0.9.117'
end

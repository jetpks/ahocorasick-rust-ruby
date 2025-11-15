# frozen_string_literal: true

require 'rake/testtask'
require 'rb_sys/extensiontask'

CROSS_PLATFORMS = %w[
  aarch64-linux
  arm64-darwin
  x86_64-darwin
  x86_64-linux
].freeze

spec = Bundler.load_gemspec('ahocorasick-rust.gemspec')

RbSys::ExtensionTask.new('rahocorasick', spec) do |ext|
  ext.lib_dir = 'lib/rahocorasick'
  ext.cross_compile = true
  ext.cross_platform = CROSS_PLATFORMS
end

Rake::TestTask.new do |t|
  t.deps << :dev << :compile
  t.test_files = FileList['test/**/*_test.rb']
end

task :dev do
  ENV['RB_SYS_CARGO_PROFILE'] = 'dev'
end

task default: :test

# frozen_string_literal: true

# Skip on platforms without C extension support
# JRuby: ruby.h is intentionally just "#error JRuby does not support native extensions"
# TruffleRuby: Has C extension support since 24.0.0, but skipping for now (installation issues)
# See JRUBY_ANALYSIS.md for details on why Magnus cannot work on JRuby
if RUBY_ENGINE == 'jruby'
  puts "Skipping native extension on #{RUBY_ENGINE}"
  puts 'MatryoshkaDemo will use pure Ruby backend'
  puts 'Note: JRuby supports FFI gem, but Magnus uses C extensions (Ruby C API).'
  puts 'See JRUBY_ANALYSIS.md for experimental RbConfig patch attempt.'
  File.write('Makefile', "all:\n\t@echo 'Skipping'\ninstall:\n\t@echo 'Skipping'\n")
  exit 0
end

# TruffleRuby 24.0.0+ has native C extension support (no longer using Sulong)
# It should work with Magnus, but needs testing with a working TruffleRuby installation
if RUBY_ENGINE == 'truffleruby'
  puts "⚠️  TruffleRuby detected - C extension support is experimental"
  puts "    TruffleRuby 24.0+ has native C extension support (should work with Magnus)"
  puts "    Attempting compilation... (may fail, will fall back to pure Ruby)"
  puts
end

# Check Cargo availability
def cargo_available?
  system('cargo --version > /dev/null 2>&1')
end

unless cargo_available?
  warn 'WARNING: Cargo not found!'
  warn 'MatryoshkaDemo will fall back to pure Ruby.'
  warn 'To enable Rust speedup, install Rust: https://rustup.rs'
  File.write('Makefile', "all:\n\t@echo 'Skipping'\ninstall:\n\t@echo 'Skipping'\n")
  exit 0
end

# Build with rb-sys
require 'mkmf'
require 'rb_sys/mkmf'

create_rust_makefile('matryoshka_demo_native/matryoshka_demo_native') do |r|
  r.ext_dir = 'ffi'
  r.profile = ENV.fetch('RB_SYS_CARGO_PROFILE', :release).to_sym
end

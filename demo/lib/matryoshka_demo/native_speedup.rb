# frozen_string_literal: true

# Check if native speedup is explicitly disabled
# Two levels:
# 1. DISABLE_MATRYOSHKA_NATIVE - disables ALL matryoshka gems
# 2. DISABLE_MATRYOSHKADEMO_NATIVE - disables only this gem
if ENV['DISABLE_MATRYOSHKA_NATIVE'] || ENV['DISABLE_MATRYOSHKADEMO_NATIVE']
  # STDERR.puts "[MatryoshkaDemo] Native speedup disabled via environment variable"
  return
end

# Attempt to load native speedup
begin
  require 'matryoshka_demo_native/matryoshka_demo_native'

  module MatryoshkaDemo
    # Native implementation module to be prepended
    module NativeSpeedup
      module ClassMethods
        def count_primes(limit)
          MatryoshkaDemoNative.count_primes(limit)
        end

        def nth_prime(n)
          MatryoshkaDemoNative.nth_prime(n)
        end
      end

      def self.prepended(base)
        base.singleton_class.prepend(ClassMethods)
      end
    end

    # Prepend native methods - they take precedence in method lookup
    PrimeCounter.prepend(NativeSpeedup)
  end

  # Optional: log success
  # STDERR.puts "[MatryoshkaDemo] Native speedup loaded (Rust via Magnus)"

rescue LoadError => e
  # Native extension not available
  # Possible reasons:
  # - No Cargo installed
  # - Compilation failed
  # - Platform without C extension support (JRuby, TruffleRuby)
  # - Development mode without running `rake compile`
  # - DISABLE_MATRYOSHKA_NATIVE env var set

  # Silently fall back to pure Ruby
  # Optional: log fallback
  # STDERR.puts "[MatryoshkaDemo] Using pure Ruby backend: #{e.message}"
end

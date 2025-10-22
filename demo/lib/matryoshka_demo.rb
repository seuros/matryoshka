# frozen_string_literal: true

require_relative 'matryoshka_demo/prime_counter'

module MatryoshkaDemo
  VERSION = '0.1.0'

  # Public API delegates to PrimeCounter
  def self.count_primes(limit)
    PrimeCounter.count_primes(limit)
  end

  def self.nth_prime(n)
    PrimeCounter.nth_prime(n)
  end
end

# Attempt to load JVM speedup (JRuby only)
begin
  require_relative 'matryoshka_demo/jvm_speedup'
rescue LoadError
  # Not JRuby or Java classes not compiled
end

# Attempt to load TruffleRuby speedup (TruffleRuby + Polyglot)
begin
  require_relative 'matryoshka_demo/truffle_speedup'
rescue LoadError
  # Not TruffleRuby or Polyglot not available
end

# Attempt to load native speedup (CRuby + Magnus)
# This will override PrimeCounter methods if successful
begin
  require_relative 'matryoshka_demo/native_speedup'
rescue LoadError
  # Native extension not available, using pure Ruby or JVM
  # This is expected on:
  # - JRuby (uses JVM backend instead)
  # - TruffleRuby (uses Polyglot or pure Ruby)
  # - Platforms without Cargo
  # - Compilation failures
  # - Development without running `rake compile`
end

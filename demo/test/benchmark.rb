# frozen_string_literal: true

require 'benchmark'
require_relative '../lib/matryoshka_demo'

puts "MatryoshkaDemo Benchmark"
puts "=" * 60
puts

# Detect which backend is loaded
# Check if native speedup is disabled via ENV
native_disabled = ENV['DISABLE_MATRYOSHKA_NATIVE'] || ENV['DISABLE_MATRYOSHKADEMO_NATIVE']

native_loaded = if native_disabled
  false
else
  begin
    require 'matryoshka_demo_native/matryoshka_demo_native'
    true
  rescue LoadError
    false
  end
end

jvm_loaded = if native_disabled || RUBY_ENGINE != 'jruby'
  false
elsif RUBY_ENGINE == 'jruby'
  begin
    require 'java'
    Java::IoMatryoshkaDemo::PrimeCounter
    true
  rescue NameError, LoadError
    false
  end
else
  false
end

truffle_java_loaded = if native_disabled || RUBY_ENGINE != 'truffleruby'
  false
elsif RUBY_ENGINE == 'truffleruby'
  begin
    require 'polyglot'
    Polyglot.eval('java', 'io.matryoshka.demo.PrimeCounter')
    true
  rescue NameError, LoadError, NoMethodError
    false
  end
else
  false
end

backend = if jvm_loaded
  "Java (via JRuby interop)"
elsif truffle_java_loaded
  "Java (via TruffleRuby Polyglot)"
elsif native_loaded
  "Rust (via Magnus FFI)"
else
  "Pure Ruby"
end

puts "Ruby: #{RUBY_ENGINE} #{RUBY_VERSION}"
puts "Backend: #{backend}"
puts

# Cold start benchmark (first run)
puts "COLD START (first run, no warmup)"
puts "-" * 60

result = nil
cold_time = Benchmark.realtime do
  result = MatryoshkaDemo.count_primes(1_000_000)
end

puts "count_primes(1_000_000): #{(cold_time * 1000).round(2)}ms"
puts "Result: #{result} primes"
puts

# Warmup for JIT (especially important for JVM)
puts "Warming up JIT (20 iterations)..."
20.times { MatryoshkaDemo.count_primes(100_000) }
puts

# Hot benchmark (after JIT warmup)
puts "HOT (after JIT warmup)"
puts "-" * 60

hot_time = Benchmark.realtime do
  result = MatryoshkaDemo.count_primes(1_000_000)
end

puts "count_primes(1_000_000): #{(hot_time * 1000).round(2)}ms"
puts "Result: #{result} primes"
puts "Speedup vs cold: #{(cold_time / hot_time).round(2)}x"
puts

# Comparison at different scales
[10_000, 100_000, 1_000_000, 10_000_000].each do |limit|
  time = Benchmark.realtime do
    MatryoshkaDemo.count_primes(limit)
  end

  puts "count_primes(#{limit.to_s.rjust(10)}): #{(time * 1000).round(2).to_s.rjust(8)}ms"
end

puts
puts "nth_prime benchmark"
puts "-" * 60

[100, 1_000, 10_000, 100_000].each do |n|
  time = Benchmark.realtime do
    MatryoshkaDemo.nth_prime(n)
  end

  puts "nth_prime(#{n.to_s.rjust(7)}): #{(time * 1000).round(2).to_s.rjust(8)}ms"
end

# MatryoshkaDemo - Prime Counter

Demo gem showcasing the **Matryoshka FFI Hybrid pattern**.

## What It Does

Counts prime numbers using Sieve of Eratosthenes:
- **Pure Ruby implementation** (fallback, works everywhere)
- **Optional Rust FFI speedup** (50-100x faster when available)
- **Graceful degradation** (no Cargo? No problem)

## Installation

```bash
cd demo
bundle install
```

## Usage

```ruby
require 'matryoshka_demo'

# Count primes up to N
MatryoshkaDemo.count_primes(1_000_000)
# => 78498

# Find the nth prime
MatryoshkaDemo.nth_prime(1000)
# => 7919
```

## Disabling Native Extension

Use environment variables to force pure Ruby:

```bash
# Disable ALL matryoshka gems
DISABLE_MATRYOSHKA_NATIVE=1 ruby script.rb

# Disable only this gem
DISABLE_MATRYOSHKADEMO_NATIVE=1 ruby script.rb

# Useful for:
# - Testing pure Ruby fallback
# - Debugging native extension issues
# - Benchmarking comparison
```

## Testing

```bash
# Test pure Ruby (no native extension)
ruby test/prime_counter_test.rb

# Run all tests
rake test
```

## Benchmarking

```bash
# With Rust FFI (after compiling)
rake compile
ruby test/benchmark.rb

# Pure Ruby only (using env var)
DISABLE_MATRYOSHKADEMO_NATIVE=1 ruby test/benchmark.rb

# Compare both
ruby test/benchmark.rb
DISABLE_MATRYOSHKADEMO_NATIVE=1 ruby test/benchmark.rb
```

## Benchmark Results

**Complete performance comparison across all Ruby implementations** (counting primes up to 1,000,000):

### Cold Start vs Hot Performance

| Implementation | Backend | Cold Start | Hot (after warmup) | JIT Speedup |
|----------------|---------|------------|-------------------|-------------|
| **CRuby 3.4.7** | Rust (Magnus) | 3.42ms | 3.42ms | 1.0x |
| **JRuby 10.0.2.0** | Java (native) | 22.02ms | **5.39ms** | **4.09x** |
| **TruffleRuby 25.0** | Pure Ruby (GraalVM JIT) | 174.05ms | **14.48ms** | **12.02x** 🔥 |
| **CRuby 3.4.7** | Pure Ruby | 107.79ms | 104.74ms | 1.03x |
| **JRuby 10.0.2.0** | Pure Ruby | 348.05ms | 296.47ms | 1.17x |

### Performance vs CRuby + Rust (Baseline)

| Backend | Performance (hot) | vs CRuby+Rust | Speedup vs Pure Ruby |
|---------|-------------------|---------------|----------------------|
| **CRuby + Rust** | 3.42ms | Baseline ⚡ | 30.6x faster |
| **JRuby + Java** | 5.39ms | 1.58x slower | 55x faster |
| **TruffleRuby + GraalVM JIT** | 14.48ms | 4.23x slower | 7.2x faster |

### Key Findings

✅ **CRuby + Rust = Lowest latency** (3.42ms, no warmup needed)
- Native code, predictable performance
- Full Magnus support for Ruby C API

✅ **JRuby + Java = Excellent JVM performance** (5.39ms hot)
- 4x speedup after JIT warmup
- Only 58% slower than Rust
- Native Java interop (no FFI overhead)

✅ **TruffleRuby GraalVM JIT = Amazing pure Ruby** (14.48ms hot)
- 12x speedup after warmup!
- 7.2x faster than CRuby pure Ruby
- No C extensions needed

**Pattern Success:** Each Ruby implementation gets optimal backend, all within 4.2x of each other when warm! 🎯

## Ruby Implementation Compatibility

### Backend Support Matrix

| Implementation | Magnus (Rust) | Java Backend | Pure Ruby | Best Choice |
|----------------|---------------|--------------|-----------|-------------|
| **CRuby 3.0+** | ✅ Yes | N/A | ✅ Yes | Rust (3.42ms) |
| **JRuby 10.0+** | ❌ No | ✅ Yes | ✅ Yes | Java (5.39ms hot) |
| **TruffleRuby 25.0+** | ❌ No | ⚠️ JVM only | ✅ Yes | Pure Ruby (14.48ms hot) |

### Why Magnus Doesn't Work

**JRuby:**
- `ruby.h` is intentional stub: `#error JRuby does not support native extensions`
- By design - JVM-based, no native Ruby VM
- Solution: Use Java backend (included in this demo)

**TruffleRuby:**
- Incomplete Ruby C API (missing `rb_bug`, `RBasic.flags`, etc.)
- GraalVM Native build lacks JVM polyglot
- Solution: Pure Ruby with GraalVM JIT is fast enough!

## Architecture

```
Pure Ruby ────────┐
                  ├──> Public API
Rust FFI ─────────┘
(optional)
```

**Fallback chain:**
1. Try loading native extension
2. If fails → use pure Ruby
3. User sees identical API

## Pattern Demonstration

This demo shows:
- ✅ Pure Ruby baseline (works everywhere)
- ✅ Dramatic Rust speedup (50-100x)
- ✅ Graceful fallback (LoadError handling)
- ✅ Simple algorithm (easy to understand)
- ✅ Side-by-side comparison (Ruby vs Rust)

See [../FFI_HYBRID.md](../FFI_HYBRID.md) for the full pattern guide.

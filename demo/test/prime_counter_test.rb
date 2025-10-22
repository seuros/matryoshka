# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../lib/matryoshka_demo'

class PrimeCounterTest < Minitest::Test
  def test_count_primes_small
    assert_equal 0, MatryoshkaDemo.count_primes(0)
    assert_equal 0, MatryoshkaDemo.count_primes(1)
    assert_equal 1, MatryoshkaDemo.count_primes(2)
    assert_equal 2, MatryoshkaDemo.count_primes(3)
    assert_equal 4, MatryoshkaDemo.count_primes(10)
  end

  def test_count_primes_100
    # Primes up to 100: 2,3,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61,67,71,73,79,83,89,97
    assert_equal 25, MatryoshkaDemo.count_primes(100)
  end

  def test_count_primes_1000
    assert_equal 168, MatryoshkaDemo.count_primes(1000)
  end

  def test_count_primes_10000
    assert_equal 1229, MatryoshkaDemo.count_primes(10_000)
  end

  def test_nth_prime_small
    assert_equal 2, MatryoshkaDemo.nth_prime(1)
    assert_equal 3, MatryoshkaDemo.nth_prime(2)
    assert_equal 5, MatryoshkaDemo.nth_prime(3)
    assert_equal 7, MatryoshkaDemo.nth_prime(4)
    assert_equal 11, MatryoshkaDemo.nth_prime(5)
  end

  def test_nth_prime_100
    # 100th prime is 541
    assert_equal 541, MatryoshkaDemo.nth_prime(100)
  end

  def test_nth_prime_1000
    # 1000th prime is 7919
    assert_equal 7919, MatryoshkaDemo.nth_prime(1000)
  end

  def test_nth_prime_invalid
    assert_nil MatryoshkaDemo.nth_prime(0)
    assert_nil MatryoshkaDemo.nth_prime(-1)
  end
end

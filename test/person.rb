# -*- encoding: utf-8 -*-
require 'hessian2'

class Person
  include Hessian2::Handler
  attr_accessor :age

  def get_person
    Hessian2::TypeWrapper.new('Person', {name: 'kimokbin', age: 16})
  end

  def get_nil
    nil
  end

  def get_true
    true
  end

  def get_false
    false
  end

  def get_fixnum
    59
  end

  def get_long
    Hessian2::TypeWrapper.new('L', 59)
  end

  def get_bignum
    9876543210
  end

  def get_float
    59.59
  end

  def get_time
    Time.new
  end

  def get_string
    '金玉彬'
  end

  def get_huge_string
    get_string * 32769
  end

  def get_array
    ['a', 'b']
  end

  def get_array_refer
    a = get_array
    [a, a]
  end

  def get_hash
    {a: 1, 'b' => 2}
  end

  def get_hash_refer
    h = get_hash
    [h, h]
  end

  def get_binary
    Hessian2::TypeWrapper.new('B', [59.59].pack('G'))
  end

  def get_huge_binary
    Hessian2::TypeWrapper.new('B', [59.59].pack('G') * 32769)
  end

  def multi_set(person, nil1, true1, false1, fixnum1, bignum1, bignum2, time1, str1, hstr1, arr1, rarr1, hash1, rhash1, bin1, hbin1)
    puts person
    puts nil1.inspect
    puts true1
    puts false1
    puts fixnum1
    puts bignum1
    puts bignum2
    puts time1
    puts str1
    puts hstr1.size
    puts arr1
    puts rarr1
    puts hash1
    puts rhash1
    puts bin1
    puts hbin1.size
  end
end

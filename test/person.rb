# -*- encoding: utf-8 -*-
require 'hessian2'

class Person
  include Hessian2::Handler

  def get_person
    Hessian2::TypeWrapper.new('Person', {name: 'kimokbin', age: 16})
  end

  def get_null
    nil
  end

  def get_true
    true
  end

  def get_false
    false
  end

  def get_int
    59
  end

  def get_wlong
    Hessian2::TypeWrapper.new('L', get_int)
  end

  def get_long
    9876543210
  end

  def get_double
    59.59
  end

  def get_date
    Time.new
  end

  def get_string
    '金玉彬'
  end

  def get_hstring
    get_string * 32769
  end

  def get_list
    ['a', 'b']
  end

  def get_rlist
    a = get_list
    [a, a]
  end

  def get_map
    {a: 1, 'b' => 2}
  end

  def get_rmap
    h = get_map
    [h, h]
  end

  def get_binary
    Hessian2::TypeWrapper.new('B', [59.59].pack('G'))
  end

  def get_hbinary
    Hessian2::TypeWrapper.new('B', IO.binread(File.expand_path("../Lighthouse.jpg", __FILE__)))
  end

  def multi_set(person,
    personlist,
    personmap,
    null1,
    true1,
    false1,
    int1,
    wlong1,
    long1,
    double1,
    date1,
    str1,
    hstr1,
    list1,
    list1r,
    rlist1,
    map1,
    map1r,
    rmap1,
    bin1, 
    hbin1)

    IO.write(File.expand_path("../#{Time.new.to_i}.txt", __FILE__), hstr1)
    IO.binwrite(File.expand_path("../#{Time.new.to_i}.bin", __FILE__), hbin1)

    puts person
    puts personlist
    puts personmap
    puts null1.inspect
    puts true1
    puts false1
    puts int1
    puts wlong1
    puts long1
    puts double1
    puts date1
    puts str1
    puts hstr1.size
    puts list1
    puts list1r
    puts rlist1
    puts map1
    puts map1r
    puts rmap1
    puts bin1
    puts hbin1.size

    nil
  end
end

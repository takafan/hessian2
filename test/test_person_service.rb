lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'

c1 = Hessian2::Client.new('http://127.0.0.1:9292/person')

begin puts c1.undefined_method; rescue Hessian2::Exception => e; puts "#{e.message}"; end
begin puts c1.multi_set; rescue Hessian2::Exception => e; puts "#{e.message}"; end

person = c1.get_person
nil1 = c1.get_nil.inspect
true1 = c1.get_true
false1 = c1.get_false
fixnum1 = c1.get_fixnum
bignum1 = c1.get_long
bignum2 = c1.get_bignum
float1 = c1.get_float
time1 = c1.get_time
str1 = c1.get_string
hstr1 = c1.get_huge_string
arr1 = c1.get_array
rarr1 = c1.get_array_refer
hash1 = c1.get_hash
rhash1 = c1.get_hash_refer
bin1 = c1.get_binary
hbin1 = c1.get_huge_binary

puts person
puts nil1.inspect
puts true1
puts false1
puts fixnum1
puts bignum1
puts bignum2
puts float1
puts time1
puts str1
puts hstr1.size
puts arr1
puts rarr1
puts hash1
puts rhash1
puts bin1
puts hbin1.size

c1.multi_set(person, 
  nil1, 
  true1, 
  false1, 
  fixnum1, 
  Hessian2::TypeWrapper.new('L', bignum1), 
  bignum2, 
  time1, 
  str1, 
  hstr1, 
  arr1,
  rarr1, 
  hash1, 
  rhash1, 
  Hessian2::TypeWrapper.new('B', bin1), 
  Hessian2::TypeWrapper.new('B', hbin1))

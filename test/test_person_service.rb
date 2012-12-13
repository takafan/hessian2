lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'

c1 = Hessian2::Client.new('http://127.0.0.1:9292/person')

begin puts c1.undefined_method; rescue Hessian2::Fault => e; puts "#{e.message}"; end
begin puts c1.multi_set; rescue Hessian2::Fault => e; puts "#{e.message}"; end

person = c1.get_person
wperson = Hessian2::TypeWrapper.new('example.Person', person)
null1 = c1.get_null.inspect
true1 = c1.get_true
false1 = c1.get_false
int1 = c1.get_int
wlong1 = c1.get_wlong
long1 = c1.get_long
double1 = c1.get_double
date1 = c1.get_date
str1 = c1.get_string
hstr1 = c1.get_hstring
list1 = c1.get_list
rlist1 = c1.get_rlist
map1 = c1.get_map
rmap1 = c1.get_rmap
bin1 = c1.get_binary
hbin1 = c1.get_hbinary

puts person
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
puts rlist1
puts map1
puts rmap1
puts bin1
puts hbin1.size

c1.multi_set(wperson,
  [wperson, wperson],
  [1 => wperson, 2 => wperson],
  null1,
  true1,
  false1,
  int1,
  Hessian2::TypeWrapper.new('L', int1),
  long1,
  double1,
  date1,
  str1,
  hstr1,
  list1,
  list1,
  rlist1,
  map1,
  map1,
  rmap1,
  Hessian2::TypeWrapper.new('B', bin1),
  Hessian2::TypeWrapper.new('B', hbin1))

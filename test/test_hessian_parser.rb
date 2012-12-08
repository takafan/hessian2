lib_path = File.expand_path('../../lib', __FILE__)
$:.unshift(lib_path)
require 'hessian2'
require 'test/unit'

class HessianParserTest < Test::Unit::TestCase
  
  include  Hessian2::HessianParser
  
  def test_integer
    assert_equal 4711, parse("r\001\000I\000\000\022gz")
  end
  def test_long
    assert_equal 2, parse("r\001\000L\000\000\000\000\000\000\000\002z")
  end  
  def test_double
    assert_equal 3.4, parse("r\001\000D@\v333333z")
  end
  def test_false
    assert_equal false, parse("r\001\000Fz")
  end
  def test_true
    assert_equal true, parse("r\001\000Tz")
  end
  def test_string
    assert_equal "string", parse("r\001\000S\000\006stringz")
  end
  def test_null
    assert_equal nil, parse("r\001\000Nz")
  end
  def test_date
    time = parse("r\001\000d\000\000\001\010\344\036\332\360z")
    assert_instance_of Time, time
    assert_equal '2006-01-19 19:23:13', time.getutc.strftime("%Y-%m-%d %H:%M:%S")
    assert_equal 520000, time.usec
  end
  def test_integer_array
    assert_equal [ 1, 2, 3 ], parse([ "r\001\000Vt\000\004[intl\000\000\000\003",
      "I\000\000\000\001I\000\000\000\002I\000\000\000\003zz" ].join)
  end
  def test_array
    assert_equal [ 'sillen', 32 ], parse([ "r\001\000Vt\000\a[objectl\000\000\000\002",
      "S\000\006sillenI\000\000\000 zz" ].join)
  end
  def test_array_in_array
    assert_equal [ 'A list', [ 9, 3 ] ], parse([ "r\001\000Vl\000\000\000\002S\000\006",
      "A listVt\000\022[java.lang.Integerl\000\000\000\002I\000\000\000\t",
      "I\000\000\000\003zzz" ].join)
  end
  def test_map
    map = { 'sillen' => 32, 'numbers' => [ 1.1, 1.2, 1.3 ] }
    assert_equal map, parse([ "r\001\000Mt\000\000S\000\anumbersVt\000\a[double",
      "l\000\000\000\003D?\361\231\231\231\231\231\232D?\363333333D?",
      "\364\314\314\314\314\314\315zS\000\006sillenI\000\000\000 zz" ].join)
  end
end

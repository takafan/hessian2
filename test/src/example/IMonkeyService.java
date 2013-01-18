package example;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Map;

public interface IMonkeyService {
	
	// 0x00..0x1f # utf-8 string length 0-31
	public String get_string_0();
	public String get_string_x1f();
	public String get_string_x1fu();
	
	public void set_string_0(String str1);
	public void set_string_x1f(String str1);
	public void set_string_x1fu(String str1);
	
	// 0x20..0x2f # binary data length 0-15
	public byte[] get_bin_0();
	public byte[] get_bin_xf();
	
	public void set_bin_0(byte[] bin1);
	public void set_bin_xf(byte[] bin1);
	
	// 0x30..0x33 # utf-8 string length 0-1023
	public String get_string_x20();
	public String get_string_x20u();
	public String get_string_x3ff();
	public String get_string_x3ffu();
	
	public void set_string_x20(String str1);
	public void set_string_x20u(String str1);
	public void set_string_x3ff(String str1);
	public void set_string_x3ffu(String str1);
	
	// 0x34..0x37 # binary data length 0-1023
	public byte[] get_bin_x10();
	public byte[] get_bin_x3ff();
	
	public void set_bin_x10(byte[] bin1);
	public void set_bin_x3ff(byte[] bin1);
	
	// 0x38..0x3f # three-octet compact long (-x40000 to x3ffff)
	public long get_long_mx801();
	public long get_long_x800();
	public long get_long_mx40000();
	public long get_long_x3ffff();
	
	public void set_long_mx801(long long1);
	public void set_long_x800(long long1);
	public void set_long_mx40000(long long1);
	public void set_long_x3ffff(long long1);
	
	// 0x41 # 8-bit binary data non-final chunk ('A')
	public byte[] get_lighthouse();
	
	public void set_lighthouse(byte[] bin1); //561276
	
	// 0x42 # 8-bit binary data final chunk ('B')
	public byte[] get_bin_x400();
	public byte[] get_bin_x8000();
	
	public void set_bin_x400(byte[] bin1);
	public void set_bin_x8000(byte[] bin1);
	
	// 0x43 # object type definition ('C') and 0x60..0x6f # object with direct type
	// 0x4d # map with type ('M')
	public Monkey get_monkey();
	
	public void set_monkey(Monkey monkey1);
	
	// 0x44 # 64-bit IEEE encoded double ('D')
	public double get_double_min();
	public double get_double_max();
	
	public void set_double_min(double double1); // 4.9E-324
	public void set_double_max(double double1); // 1.7976931348623157E308
	
	// 0x46 # boolean false ('F')
	public boolean get_false();
	
	public void set_false(boolean false1);
	
	// 0x48 # untyped map ('H')
	public Map<String, Object> get_map_h();
	
	public void set_map_h(Map<String, Object> map1);
	
	// 0x49 # 32-bit signed integer ('I')
	public int get_int_mx40001();
	public int get_int_x40000();
	public int get_int_mx40_000_000();
	public int get_int_x3f_fff_fff();
	
	public void set_int_mx40001(int int1);
	public void set_int_x40000(int int1);
	public void set_int_mx40_000_000(int int1);
	public void set_int_x3f_fff_fff(int int1);
	
	// 0x4a # 64-bit UTC millisecond date
	public Date get_date_20130112145959();
	
	public void set_date_20130112145959(Date date1);
	
	// 0x4b # 32-bit UTC minute date
	public Date get_date_201301121459();
	
	public void set_date_201301121459(Date date1);
	
	// 0x4c # 64-bit signed long integer ('L')
	public long get_long_mx80_000_001();
	public long get_long_x80_000_000();
	public long get_long_mx8_000_000_000_000_000();
	public long get_long_x7_fff_fff_fff_fff_fff();
	
	public void set_long_mx80_000_001(long long1);
	public void set_long_x80_000_000(long long1);
	public void set_long_mx8_000_000_000_000_000(long long1);
	public void set_long_x7_fff_fff_fff_fff_fff(long long1);
	
	// 0x4d # map with type ('M')
	public Monkey get_map();

	public void set_map(Monkey map1);
	
	// 0x4e # null ('N')
	public Object get_null();
	
	public void set_null(Object obj);
	
	// 0x4f # object instance ('O')
	public ArrayList<Monkey> get_monkeys();
	
	public void set_monkeys(ArrayList<Monkey> monkeys);
	
	// 0x51 # reference to map/list/object - integer ('Q')
	public ArrayList<Map<String, Object>> get_map_h_map_h();
	public ArrayList<List> get_direct_untyped_list_list();
	public ArrayList<List> get_untyped_list_list();
	public ArrayList<int[]> get_direct_list_list();
	public ArrayList<int[]> get_list_list();
	public ArrayList<Monkey> get_monkey_monkey();
	
	public void set_map_list_monkey_map_list_monkey(Map<String, Object> map1, int[] list1, Monkey monkey1, 
			Map<String, Object> map2, int[] list2, Monkey monkey2);
	
	// 0x52 # utf-8 string non-final chunk ('R')
	public String get_string_x8001();
	public String get_string_x8001u();
	
	public void set_string_x8001(String str1);
	public void set_string_x8001u(String str1);
	
	// 0x53 # utf-8 string final chunk ('S')
	public String get_string_x400();
	public String get_string_x400u();
	public String get_string_x8000();
	public String get_string_x8000u();
	
	public void set_string_x400(String str1);
	public void set_string_x400u(String str1);
	public void set_string_x8000(String str1);
	public void set_string_x8000u(String str1);
	
	// 0x54 # boolean true ('T')
	public boolean get_true();
	
	public void set_true(boolean true1);
	
	// 0x56 # fixed-length list/vector ('V')
	// 0x58 # fixed-length untyped list/vector ('X')
	public int[] get_list();
	public List get_untyped_list();
	
	public void set_list(int[] list1);
	
	// 0x59 # long encoded as 32-bit int ('Y')
	public long get_long_mx40001();
	public long get_long_x40000();
	public long get_long_mx80_000_000();
	public long get_long_x7f_fff_fff();
	
	public void set_long_mx40001(long long1);
	public void set_long_x40000(long long1);
	public void set_long_mx80_000_000(long long1);
	public void set_long_x7f_fff_fff(long long1);
	
	// 0x5b # double 0.0
	public double get_double_0();
	
	public void set_double_0(double double1);
	
	// 0x5c # double 1.0
	public double get_double_1();
	
	public void set_double_1(double double1);
	
	// 0x5d # double represented as byte (-128.0 to 127.0)
	public double get_double_m128();
	public double get_double_127();
	
	public void set_double_m128(double double1);
	public void set_double_127(double double1);
	
	// 0x5e # double represented as short (-32768.0 to 32767.0)
	public double get_double_m129();
	public double get_double_128();
	public double get_double_m32768();
	public double get_double_32767();
	
	public void set_double_m129(double double1);
	public void set_double_128(double double1);
	public void set_double_m32768(double double1);
	public void set_double_32767(double double1);
	
	// 0x70..0x77 # fixed list with direct length 
	// 0x78..0x7f # fixed untyped list with direct length
	public int[] get_list_size0();
	public int[] get_list_size7();
	public List get_untyped_list_size0();
	public List get_untyped_list_size7();
	
	public void set_list_size0(int[] list1);
	public void set_list_size7(int[] list1);
	
	// 0x80..0xbf # one-octet compact int (-x10 to x3f, x90 is 0)
	public int get_int_mx10();
	public int get_int_x3f();
	
	public void set_int_mx10(int int1);
	public void set_int_x3f(int int1);
	
	// 0xc0..0xcf # two-octet compact int (-x800 to x7ff)
	public int get_int_mx11();
	public int get_int_x40();
	public int get_int_mx800();
	public int get_int_x7ff();
	
	public void set_int_mx11(int int1);
	public void set_int_x40(int int1);
	public void set_int_mx800(int int1);
	public void set_int_x7ff(int int1);
	
	// 0xd0..0xd7 # three-octet compact int (-x40000 to x3ffff)
	public int get_int_mx801();
	public int get_int_x800();
	public int get_int_mx40000();
	public int get_int_x3ffff();
	
	public void set_int_mx801(int int1);
	public void set_int_x800(int int1);
	public void set_int_mx40000(int int1);
	public void set_int_x3ffff(int int1);
	
	// 0xd8..0xef # one-octet compact long (-x8 to xf, xe0 is 0)
	public long get_long_mx8();
	public long get_long_xf();
	
	public void set_long_mx8(long long1);
	public void set_long_xf(long long1);
	
	// 0xf0..0xff # two-octet compact long (-x800 to x7ff, xf8 is 0)
	public long get_long_mx9();
	public long get_long_x10();
	public long get_long_mx800();
	public long get_long_x7ff();
	
	public void set_long_mx9(long long1);
	public void set_long_x10(long long1);
	public void set_long_mx800(long long1);
	public void set_long_x7ff(long long1);
	
}

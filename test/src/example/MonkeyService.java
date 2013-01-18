package example;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.servlet.ServletContextHandler;
import org.eclipse.jetty.servlet.ServletHolder;

import com.caucho.hessian.server.HessianServlet;

public class MonkeyService extends HessianServlet implements IMonkeyService {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	public static void main(String[] args) throws Exception {
        Server server = new Server(9292);
        ServletContextHandler context = new ServletContextHandler(
        ServletContextHandler.SESSIONS);
        server.setHandler(context);
        ServletHolder servletHolder = new ServletHolder(new MonkeyService());
        context.addServlet(servletHolder, "/monkey");
        server.start();
        server.join(); 

    }
	
	// 0x00..0x1f # utf-8 string length 0-31
	public String get_string_0()
	{
		return "";
	}
	
	public String get_string_x1f()
	{
		StringBuilder sb = new StringBuilder();
		for(int i = 0; i < 0x1f; i++)
		{
			sb.append("j");
		}
		return sb.toString();
	}
	
	public String get_string_x1fu()
	{
		StringBuilder sb = new StringBuilder();
		for(int i = 0; i < 0x1f; i++)
		{
			sb.append("金");
		}
		return sb.toString();
	}
	
	public void set_string_0(String string1)
	{
		boolean isT = string1.isEmpty();
		printAssert("set_string_0", isT);
	}
	
	public void set_string_x1f(String string1)
	{
		boolean isT = string1.charAt(0) == 'j' && string1.length() == 0x1f;
		printAssert("set_string_x1f", isT);
	}
	
	public void set_string_x1fu(String string1)
	{
		boolean isT = string1.charAt(0) == '金' && string1.length() == 0x1f;
		printAssert("set_string_x1fu", isT);
	}
	
	// 0x20..0x2f # binary data length 0-15
	public byte[] get_bin_0()
	{
		return new byte[0];
	}
	
	public byte[] get_bin_xf()
	{
		return new byte[0xf];
	}
	
	public void set_bin_0(byte[] bin1)
	{
		boolean isT = bin1.length == 0;
		printAssert("set_bin_0", isT);
	}
	
	public void set_bin_xf(byte[] bin1)
	{
		boolean isT = bin1.length == 0xf;
		printAssert("set_bin_xf", isT);
	}
	
	// 0x30..0x33 # utf-8 string length 0-1023
	public String get_string_x20()
	{
		StringBuilder sb = new StringBuilder();
		for(int i = 0; i < 0x20; i++)
		{
			sb.append("j");
		}
		return sb.toString();
	}
	
	public String get_string_x20u()
	{
		StringBuilder sb = new StringBuilder();
		for(int i = 0; i < 0x20; i++)
		{
			sb.append("金");
		}
		return sb.toString();
	}
	
	public String get_string_x3ff()
	{
		StringBuilder sb = new StringBuilder();
		for(int i = 0; i < 0x3ff; i++)
		{
			sb.append("j");
		}
		return sb.toString();
	}
	
	public String get_string_x3ffu()
	{
		StringBuilder sb = new StringBuilder();
		for(int i = 0; i < 0x3ff; i++)
		{
			sb.append("金");
		}
		return sb.toString();
	}
	
	public void set_string_x20(String string1)
	{
		boolean isT = string1.charAt(0) == 'j' && string1.length() == 0x20;
		printAssert("set_string_x20", isT);
	}
	
	public void set_string_x20u(String string1)
	{
		boolean isT = string1.charAt(0) == '金' && string1.length() == 0x20;
		printAssert("set_string_x20u", isT);
	}
	
	public void set_string_x3ff(String string1)
	{
		boolean isT = string1.charAt(0) == 'j' && string1.length() == 0x3ff;
		printAssert("set_string_x3ff", isT);
	}
	
	public void set_string_x3ffu(String string1)
	{
		boolean isT = string1.charAt(0) == '金' && string1.length() == 0x3ff;		
		printAssert("set_string_x3ffu", isT);
	}
	
	// 0x34..0x37 # binary data length 0-1023
	public byte[] get_bin_x10()
	{
		return new byte[0x10];
	}
	
	public byte[] get_bin_x3ff()
	{
		return new byte[0x3ff];
	}
	
	public void set_bin_x10(byte[] bin1)
	{
		boolean isT = bin1.length == 0x10;
		printAssert("set_bin_x10", isT);
	}
	
	public void set_bin_x3ff(byte[] bin1)
	{
		boolean isT = bin1.length == 0x3ff;
		printAssert("set_bin_x3ff", isT);
	}
	
	// 0x38..0x3f # three-octet compact long (-x40000 to x3ffff)
	public long get_long_mx801()
	{
		return -0x801L;
	}
	
	public long get_long_x800()
	{
		return 0x800L;
	}
	
	public long get_long_mx40000()
	{
		return -0x40000L;
	}
	
	public long get_long_x3ffff()
	{
		return 0x3ffffL;
	}
	
	public void set_long_mx801(long long1)
	{
		boolean isT = long1 == -0x801L;
		printAssert("set_long_mx801", isT);
	}
	
	public void set_long_x800(long long1)
	{
		boolean isT = long1 == 0x800L;
		printAssert("set_long_x800", isT);
	}
	
	public void set_long_mx40000(long long1)
	{
		boolean isT = long1 == -0x40000L;
		printAssert("set_long_mx40000", isT);
	}
	
	public void set_long_x3ffff(long long1)
	{
		boolean isT = long1 == 0x3ffffL;
		printAssert("set_long_x3ffff", isT);
	}
	
	// 0x41 # 8-bit binary data non-final chunk ('A')
	public byte[] get_lighthouse()
	{
		return new byte[561276];
	}
	
	public void set_lighthouse(byte[] bin1)
	{
		boolean isT = bin1.length == 561276;
		printAssert("set_lighthouse", isT);
	}
	
	// 0x42 # 8-bit binary data final chunk ('B')
	public byte[] get_bin_x400()
	{
		return new byte[0x400];
	}
	
	public byte[] get_bin_x8000()
	{
		return new byte[0x8000];
	}
	
	public void set_bin_x400(byte[] bin1)
	{
		boolean isT = bin1.length == 0x400;
		printAssert("set_bin_x400", isT);
	}
	
	public void set_bin_x8000(byte[] bin1)
	{
		boolean isT = bin1.length == 0x8000;
		printAssert("set_bin_x8000", isT);
	}
	
	// 0x43 # object type definition ('C') and 0x60..0x6f # object with direct type
	// 0x4d # map with type ('M')
	public Monkey get_monkey()
	{
		Monkey monkey1 = new Monkey();
		monkey1.name = "阿门";
		monkey1.age = 7;
		return monkey1;
	}
	
	public void set_monkey(Monkey monkey1)
	{
		boolean isT = monkey1.name.equals("阿门") && monkey1.age == 7;
		printAssert("set_monkey", isT);
	}
	
	// 0x44 # 64-bit IEEE encoded double ('D')
	public double get_double_min()
	{
		return Double.MIN_VALUE;
	}
	
	public double get_double_max()
	{
		return Double.MAX_VALUE;
	}
	
	public void set_double_min(double double1)
	{
		boolean isT = double1 == Double.MIN_VALUE;
		printAssert("set_double_min", isT);
	}
	
	public void set_double_max(double double1)
	{
		boolean isT = double1 == Double.MAX_VALUE;
		printAssert("set_double_max", isT);
	}
	
	// 0x46 # boolean false ('F')
	public boolean get_false()
	{
		return false;
	}
	
	public void set_false(boolean false1)
	{
		boolean isT = !false1;
		printAssert("set_false", isT);
	}
	
	// 0x48 # untyped map ('H')
	public Map<String, Object> get_map_h()
	{
		Map<String, Object> map1 = new HashMap<String, Object>();
		map1.put("name", "阿门");
		map1.put("age", 7);
		return map1;
	}
	
	public void set_map_h(Map<String, Object> map1)
	{
		boolean isT = map1.get("name").equals("阿门") && map1.get("age").equals(7);
		printAssert("set_map_h", isT);
	}
	
	// 0x49 # 32-bit signed integer ('I')
	public int get_int_mx40001()
	{
		return -0x40001;
	}
	
	public int get_int_x40000()
	{
		return 0x40000;
	}
	
	public int get_int_mx40_000_000()
	{
		return -0x40000000;
	}
	
	public int get_int_x3f_fff_fff()
	{
		return 0x3fffffff;
	}
	
	public void set_int_mx40001(int int1)
	{
		boolean isT = int1 == -0x40001;
		printAssert("set_int_mx40001", isT);
	}
	
	public void set_int_x40000(int int1)
	{
		boolean isT = int1 == 0x40000;
		printAssert("set_int_x40000", isT);
	}
	
	public void set_int_mx40_000_000(int int1)
	{
		boolean isT = int1 == -0x40000000;
		printAssert("set_int_mx40_000_000", isT);
	}
	
	public void set_int_x3f_fff_fff(int int1)
	{
		boolean isT = int1 == 0x3fffffff;
		printAssert("set_int_x3f_fff_fff", isT);
	}
	
	// 0x4a # 64-bit UTC millisecond date
	public Date get_date_20130112145959()
	{
		return new Date(1357973999000L);
	}
	
	public void set_date_20130112145959(Date date1)
	{
		boolean isT = date1.equals(new Date(1357973999000L));
		printAssert("set_date", isT);
	}
	
	// 0x4b # 32-bit UTC minute date
	public Date get_date_201301121459()
	{
		return new Date(1357973940000L);
	}
	
	public void set_date_201301121459(Date date1)
	{
		boolean isT = date1.equals(new Date(1357973940000L));
		printAssert("set_date_min", isT);
	}
	
	// 0x4c # 64-bit signed long integer ('L')
	public long get_long_mx80_000_001()
	{
		return -0x80000001L;
	}
	
	public long get_long_x80_000_000()
	{
		return 0x80000000L;
	}
	
	public long get_long_mx8_000_000_000_000_000()
	{
		return -0x8000000000000000L;
	}
	
	public long get_long_x7_fff_fff_fff_fff_fff()
	{
		return 0x7fffffffffffffffL;
	}
	
	public void set_long_mx80_000_001(long long1)
	{
		boolean isT = long1 == -0x80000001L;
		printAssert("set_long_mx80_000_001", isT);
	}
	
	public void set_long_x80_000_000(long long1)
	{
		boolean isT = long1 == 0x80000000L;
		printAssert("set_long_x80_000_000", isT);
	}
	
	public void set_long_mx8_000_000_000_000_000(long long1)
	{
		boolean isT = long1 == -0x8000000000000000L;
		printAssert("set_long_mx8_000_000_000_000_000", isT);
	}
	
	public void set_long_x7_fff_fff_fff_fff_fff(long long1)
	{
		boolean isT = long1 == 0x7fffffffffffffffL;
		printAssert("set_long_x7_fff_fff_fff_fff_fff", isT);
	}
	
	// 0x4d # map with type ('M')
	public Monkey get_map()
	{
		Monkey monkey1 = new Monkey();
		monkey1.name = "阿门";
		monkey1.age = 7;
		return monkey1;
	}

	public void set_map(Monkey map1)
	{
		boolean isT = map1.name.equals("阿门") && map1.age == 7;
		printAssert("set_map", isT);
	}
	
	// 0x4e # null ('N')
	public Object get_null()
	{
		return null;
	}
	
	public void set_null(Object obj)
	{
		boolean isT = obj == null;
		printAssert("set_null", isT);
	}
	
	// 0x4f # object instance ('O')
	public ArrayList<Monkey> get_monkeys()
	{
		Monkey monkey1 = new Monkey();
		monkey1.name = "阿门";
		monkey1.age = 7;
		Monkey monkey2 = new Monkey();
		monkey2.name = "大鸡";
		monkey2.age = 6;
		ArrayList<Monkey> arr = new ArrayList<Monkey>();
		arr.add(monkey1);
		arr.add(monkey2);
		return arr;
	}
	
	public void set_monkeys(ArrayList<Monkey> monkeys)
	{
		boolean isT = monkeys.size() == 0x11;
		printAssert("set_monkeys", isT);
	}
	
	// 0x51 # reference to map/list/object - integer ('Q')
	public ArrayList<Map<String, Object>> get_map_h_map_h()
	{
		Map<String, Object> map1 = new HashMap<String, Object>();
		map1.put("name", "阿门");
		map1.put("age", 7);
//		Map<String, Object> map2 = new HashMap<String, Object>();
//		map2.put("name", "大鸡");
//		map2.put("age", 6);
		ArrayList<Map<String, Object>> arr = new ArrayList<Map<String, Object>>();
		arr.add(map1);
		arr.add(map1);
		return arr;
	}
	
	public ArrayList<int[]> get_direct_list_list()
	{
		int[] list1 = new int[]{1,2,3,4,5,6,7};
		ArrayList<int[]> arr = new ArrayList<int[]>();
		arr.add(list1);
		arr.add(list1);
		return arr;
	}
	
	public ArrayList<int[]> get_list_list()
	{
		int[] list1 = new int[]{1,2,3,4,5,6,7,1,2,3,4,5,6,7};
		ArrayList<int[]> arr = new ArrayList<int[]>();
		arr.add(list1);
		arr.add(list1);
		return arr;
	}
	
	public ArrayList<List> get_direct_untyped_list_list()
	{
		List list1 = new ArrayList();
		for(int i = 1; i <= 7; i++)
		{
			list1.add(i);
		}
		ArrayList<List> arr = new ArrayList<List>();
		arr.add(list1);
		arr.add(list1);
		return arr;
	}
	
	public ArrayList<List> get_untyped_list_list()
	{
		List list1 = new ArrayList();
		for(int i = 1; i <= 7; i++)
		{
			list1.add(i);
		}
		for(int i = 1; i <= 7; i++)
		{
			list1.add(i);
		}
		ArrayList<List> arr = new ArrayList<List>();
		arr.add(list1);
		arr.add(list1);
		return arr;
	}
	
	public ArrayList<Monkey> get_monkey_monkey()
	{
		Monkey monkey1 = new Monkey();
		monkey1.name = "阿门";
		monkey1.age = 7;
		ArrayList<Monkey> arr = new ArrayList<Monkey>();
		arr.add(monkey1);
		arr.add(monkey1);
		return arr;
	}
	
	public void set_map_list_monkey_map_list_monkey(Map<String, Object> map1, int[] list1, Monkey monkey1, 
			Map<String, Object> map2, int[] list2, Monkey monkey2)
	{
		boolean isT = map1.get("name") == map2.get("name") && list1[0] == list2[0] && monkey1.name == monkey2.name;
		printAssert("set_map_list_monkey_map_list_monkey", isT);
	}
	
	// 0x52 # utf-8 string non-final chunk ('R')
	public String get_string_x8001()
	{
		StringBuilder sb = new StringBuilder();
		for(int i = 0; i < 0x8001; i++)
		{
			sb.append("j");
		}
		return sb.toString();
	}
	
	public String get_string_x8001u()
	{
		StringBuilder sb = new StringBuilder();
		for(int i = 0; i < 0x8001; i++)
		{
			sb.append("金");
		}
		return sb.toString();
	}
	
	public void set_string_x8001(String string1)
	{
		boolean isT = string1.length() == 0x8001 && string1.charAt(0) == 'j';
		printAssert("set_string_x8001", isT);
	}
	
	public void set_string_x8001u(String string1)
	{
		boolean isT = string1.length() == 0x8001 && string1.charAt(0) == '金';
		printAssert("set_string_x8001u", isT);
	}
	
	// 0x53 # utf-8 string final chunk ('S')
	public String get_string_x400()
	{
		StringBuilder sb = new StringBuilder();
		for(int i = 0; i < 0x400; i++)
		{
			sb.append("j");
		}
		return sb.toString();
	}
	
	public String get_string_x400u()
	{
		StringBuilder sb = new StringBuilder();
		for(int i = 0; i < 0x400; i++)
		{
			sb.append("金");
		}
		return sb.toString();
	}
	
	public String get_string_x8000()
	{
		StringBuilder sb = new StringBuilder();
		for(int i = 0; i < 0x8000; i++)
		{
			sb.append("j");
		}
		return sb.toString();
	}
	
	public String get_string_x8000u()
	{
		StringBuilder sb = new StringBuilder();
		for(int i = 0; i < 0x8000; i++)
		{
			sb.append("金");
		}
		return sb.toString();
	}
	
	public void set_string_x400(String string1)
	{
		boolean isT = string1.length() == 0x400 && string1.charAt(0) == 'j';
		printAssert("set_string_x400", isT);
	}
	
	public void set_string_x400u(String string1)
	{
		boolean isT = string1.length() == 0x400 && string1.charAt(0) == '金';
		printAssert("set_string_x400u", isT);
	}
	
	public void set_string_x8000(String string1)
	{
		boolean isT = string1.length() == 0x8000 && string1.charAt(0) == 'j';
		printAssert("set_string_x8000", isT);
	}
	
	public void set_string_x8000u(String string1)
	{
		boolean isT = string1.length() == 0x8000 && string1.charAt(0) == '金';
		printAssert("set_string_x8000u", isT);
	}
	
	// 0x54 # boolean true ('T')
	public boolean get_true()
	{
		return true;
	}
	
	public void set_true(boolean true1)
	{
		boolean isT = true1; 
		printAssert("set_true", isT);
	}
	
	// 0x56 # fixed-length list/vector ('V')
	// 0x58 # fixed-length untyped list/vector ('X')
	public int[] get_list()
	{
		return new int[]{1,2,3,4,5,6,7,1,2,3,4,5,6,7};
	}
	
	public List get_untyped_list()
	{
		List list1 = new ArrayList();
		for(int i = 1; i <= 7; i++)
		{
			list1.add(i);
		}
		for(int i = 1; i <= 7; i++)
		{
			list1.add(i);
		}
		return list1;
	}
	
	public void set_list(int[] list1)
	{
		boolean isT = list1.length == 14 && list1[0] == 1; 
		printAssert("set_list", isT);
	}
	
	// 0x59 # long encoded as 32-bit int ('Y')
	public long get_long_mx40001()
	{
		return -0x40001L;
	}
	
	public long get_long_x40000()
	{
		return 0x40000L;
	}
	
	public long get_long_mx80_000_000()
	{
		return -0x80000000L;
	}
	
	public long get_long_x7f_fff_fff()
	{
		return 0x7fffffffL;
	}
	
	public void set_long_mx40001(long long1)
	{
		boolean isT = long1 == -0x40001L;
		printAssert("set_long_mx40001", isT);
	}
	
	public void set_long_x40000(long long1)
	{
		boolean isT = long1 == 0x40000L;
		printAssert("set_long_x40000", isT);
	}
	
	public void set_long_mx80_000_000(long long1)
	{
		boolean isT = long1 == -0x80000000L;
		printAssert("set_long_mx80_000_000", isT);
	}
	
	public void set_long_x7f_fff_fff(long long1)
	{
		boolean isT = long1 == 0x7fffffffL;
		printAssert("set_long_x7f_fff_fff", isT);
	}
	
	// 0x5b # double 0.0
	public double get_double_0()
	{
		return 0.0;
	}
	
	public void set_double_0(double double1)
	{
		boolean isT = double1 == 0.0;
		printAssert("set_double_0", isT);
	}
	
	// 0x5c # double 1.0
	public double get_double_1()
	{
		return 1.0;
	}
	
	public void set_double_1(double double1)
	{
		boolean isT = double1 == 1.0;
		printAssert("set_double_1", isT);
	}
	
	// 0x5d # double represented as byte (-128.0 to 127.0)
	public double get_double_m128()
	{
		return -128.0;
	}
	
	public double get_double_127()
	{
		return 127.0;
	}
	
	public void set_double_m128(double double1)
	{
		boolean isT = double1 == -128.0;
		printAssert("set_double_mx80", isT);
	}
	
	public void set_double_127(double double1)
	{
		boolean isT = double1 == 127.0;
		printAssert("set_double_x7f", isT);
	}
	
	// 0x5e # double represented as short (-32768.0 to 32767.0)
	public double get_double_m129()
	{
		return -129.0;
	}
	
	public double get_double_128()
	{
		return 128.0;
	}
	
	public double get_double_m32768()
	{
		return -32768.0;
	}
	
	public double get_double_32767()
	{
		return 32767.0;
	}
	
	public void set_double_m129(double double1)
	{
		boolean isT = double1 == -129.0;
		printAssert("set_double_mx81", isT);
	}
	
	public void set_double_128(double double1)
	{
		boolean isT = double1 == 128.0;
		printAssert("set_double_x80", isT);
	}
	
	public void set_double_m32768(double double1)
	{
		boolean isT = double1 == -32768.0;
		printAssert("set_double_mx8000", isT);
	}
	
	public void set_double_32767(double double1)
	{
		boolean isT = double1 == 32767.0;
		printAssert("set_double_x7fff", isT);
	}
	
	// 0x70..0x77 # fixed list with direct length 
	// 0x78..0x7f # fixed untyped list with direct length
	public int[] get_list_size0()
	{
		return new int[]{};
	}
	
	public int[] get_list_size7()
	{
		return new int[]{1,2,3,4,5,6,7};
	}
	
	public List get_untyped_list_size0()
	{
		return new ArrayList();
	}
	
	public List get_untyped_list_size7()
	{
		List list1 = new ArrayList();
		for(int i = 1; i <= 7; i++)
		{
			list1.add(i);
		}
		return list1;
	}
	
	public void set_list_size0(int[] list1)
	{
		boolean isT = list1.length == 0;
		printAssert("set_list_size0", isT);
	}
	
	public void set_list_size7(int[] list1)
	{
		boolean isT = list1.length == 7 && list1[0] == 1;
		printAssert("set_list_size7", isT);
	}
	
	// 0x80..0xbf # one-octet compact int (-x10 to x3f, x90 is 0)
	public int get_int_mx10()
	{
		return -0x10;
	}
	
	public int get_int_x3f()
	{
		return 0x3f;
	}
	
	public void set_int_mx10(int int1)
	{
		boolean isT = int1 == -0x10;
		printAssert("set_int_mx10", isT);
	}
	
	public void set_int_x3f(int int1)
	{
		boolean isT = int1 == 0x3f;
		printAssert("set_int_x3f", isT);
	}
	
	// 0xc0..0xcf # two-octet compact int (-x800 to x7ff)
	public int get_int_mx11()
	{
		return -0x11;
	}
	
	public int get_int_x40()
	{
		return 0x40;
	}
	
	public int get_int_mx800()
	{
		return -0x800;
	}
	
	public int get_int_x7ff()
	{
		return 0x7ff;
	}
	
	public void set_int_mx11(int int1)
	{
		boolean isT = int1 == -0x11;
		printAssert("set_int_mx11", isT);
	}
	
	public void set_int_x40(int int1)
	{
		boolean isT = int1 == 0x40;
		printAssert("set_int_x40", isT);
	}
	
	public void set_int_mx800(int int1)
	{
		boolean isT = int1 == -0x800;
		printAssert("set_int_mx800", isT);
	}
	
	public void set_int_x7ff(int int1)
	{
		boolean isT = int1 == 0x7ff;
		printAssert("set_int_x7ff", isT);
	}
	
	// 0xd0..0xd7 # three-octet compact int (-x40000 to x3ffff)
	public int get_int_mx801()
	{
		return -0x801;
	}
	
	public int get_int_x800()
	{
		return 0x800;
	}
	
	public int get_int_mx40000()
	{
		return -0x40000;
	}
	
	public int get_int_x3ffff()
	{
		return 0x3ffff;
	}
	
	public void set_int_mx801(int int1)
	{
		boolean isT = int1 == -0x801;
		printAssert("set_int_set_int_mx801", isT);
	}
	
	public void set_int_x800(int int1)
	{
		boolean isT = int1 == 0x800;
		printAssert("set_int_x800", isT);
	}
	
	public void set_int_mx40000(int int1)
	{
		boolean isT = int1 == -0x40000;
		printAssert("set_int_mx40000", isT);
	}
	
	public void set_int_x3ffff(int int1)
	{
		boolean isT = int1 == 0x3ffff;
		printAssert("set_int_x3ffff", isT);
	}
	
	// 0xd8..0xef # one-octet compact long (-x8 to xf, xe0 is 0)
	public long get_long_mx8()
	{
		return -0x8L;
	}
	
	public long get_long_xf()
	{
		return 0xfL;
	}
	
	public void set_long_mx8(long long1)
	{
		boolean isT = long1 == -0x8L;
		printAssert("set_long_mx8", isT);
	}
	
	public void set_long_xf(long long1)
	{
		boolean isT = long1 == 0xfL;
		printAssert("set_long_xf", isT);
	}
	
	// 0xf0..0xff # two-octet compact long (-x800 to x7ff, xf8 is 0)
	public long get_long_mx9()
	{
		return -0x9L;
	}
	
	public long get_long_x10()
	{
		return 0x10L;
	}
	
	public long get_long_mx800()
	{
		return -0x800L;
	}
	
	public long get_long_x7ff()
	{
		return 0x7ffL;
	}
	
	public void set_long_mx9(long long1)
	{
		boolean isT = long1 == -0x9L;
		printAssert("set_long_mx9", isT);
	}
	
	public void set_long_x10(long long1)
	{
		boolean isT = long1 == 0x10L;
		printAssert("set_long_x10", isT);
	}
	
	public void set_long_mx800(long long1)
	{
		boolean isT = long1 == -0x800L;
		printAssert("set_long_mx800", isT);
	}
	
	public void set_long_x7ff(long long1)
	{
		boolean isT = long1 == 0x7ffL;
		printAssert("set_long_x7ff", isT);
	}
	
	private void printAssert(String meth, boolean isT)
	{
		System.out.println((isT ? "." : "fail") + " " + meth);
	}
	
}

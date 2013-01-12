package example;

import java.util.ArrayList;
import java.util.Date;
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
	
//	public Monkey get_monkey()
//	{
//		Monkey monkey1 = new Monkey();
//		monkey1.setName("金玉彬");
//		monkey1.setAge(18);
//		
//		return monkey1;
//	}
//	
//	public Monkey get_null()
//	{
//		return null;
//	}
//	
//	public boolean get_true()
//	{
//		return true;
//	}
//	
//	public boolean get_false()
//	{
//		return false;
//	}
//	
//	public int get_int()
//	{
//		return 300;
//	}
//	
//	public long get_long()
//	{
//		return 9876543210L;
//	}
//	
//	public long get_wlong()
//	{
//		return 59L;
//	}
//	
//	public double get_double()
//	{
//		return 12.25;
//	}
//	
//	public Date get_date()
//	{
//		return new Date();
//	}
//	
//	public String get_string()
//	{
//		return "金玉彬";
//	}
//	
//	public String get_hstring()
//	{
//		String str = get_string();
//		return str;
//	}
//	
//	public String[] get_list()
//	{
//		String[] list = {"a", "b", "c"};
//		return list;
//	}
//	
//	public ArrayList<String[]> get_rlist()
//	{
//		ArrayList<String[]> arr = new ArrayList<String[]>();
//		String[] l = get_list();
//		arr.add(l);
//		arr.add(l);
//		return arr;
//	}
//
//	public Map<String, Integer> get_map()
//	{
//		Map<String, Integer> m = new HashMap<String, Integer>();
//		m.put("a", 1);
//		m.put("b", 2);
//		return m;
//	}
//	
//	public ArrayList<Map<String, Integer>> get_rmap()
//	{
//		ArrayList<Map<String, Integer>> arr = new ArrayList<Map<String, Integer>>();
//		Map<String, Integer> m = get_map();
//		arr.add(m);
//		arr.add(m);
//		return arr;
//	}
//	
//	public byte[] get_binary()
//	{
//		byte[] b = {};
//		return b;
//	}
//	
//	public byte[] get_hbinary()
//	{
//		return get_binary();
//	}
	
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
	
	public void set_lighthouse(byte[] bin1)
	{
		boolean isT = bin1.length == 561276;
		printAssert("set_lighthouse", isT);
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
	
	public void set_monkey_monkey(Monkey monkey1, Monkey monkey2)
	{
		boolean isT = monkey1.name.equals("阿门") && monkey1.age == 7 && monkey2.name.equals("大鸡") && monkey2.age == 6;
		printAssert("set_monkey_monkey", isT);
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
	
	public void set_false(boolean false1)
	{
		boolean isT = !false1;
		printAssert("set_false", isT);
	}
	
	public void set_map_h(Map<String, Object> map1)
	{
		boolean isT = map1.get("name").equals("阿门") && map1.get("age").equals(7);
		printAssert("set_map_h", isT);
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
	
	public void set_date_20130112145959(Date date1)
	{
		boolean isT = date1.equals(new Date(1357973999000L));
		printAssert("set_date", isT);
	}
	
	public void set_date_201301121459(Date date1)
	{
		boolean isT = date1.equals(new Date(1357973940000L));
		printAssert("set_date_min", isT);
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

	public void set_null(Object obj)
	{
		boolean isT = obj == null;
		printAssert("set_null", isT);
	}
	
	public void set_monkeys(ArrayList<Monkey> monkeys)
	{
		boolean isT = monkeys.size() == 0x11;
		printAssert("set_monkeys", isT);
	}
	
	public void set_map_list_monkey_map_list_monkey(Map<String, Object> map1, int[] list1, Monkey monkey1, 
			Map<String, Object> map2, int[] list2, Monkey monkey2)
	{
		boolean isT = map1.get("name") == map2.get("name") && list1[0] == list2[0] && monkey1.name == monkey2.name;
		printAssert("set_map_list_monkey_map_list_monkey", isT);
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
	
	public void set_true(boolean true1)
	{
		boolean isT = true1; 
		printAssert("set_true", isT);
	}

	public void set_list(int[] list1)
	{
		boolean isT = list1.length == 14 && list1[0] == 1; 
		printAssert("set_list", isT);
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

	public void set_double_0(double double1)
	{
		boolean isT = double1 == 0D;
		printAssert("set_double_0", isT);
	}
	
	public void set_double_1(double double1)
	{
		boolean isT = double1 == 1D;
		printAssert("set_double_1", isT);
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
	
	public void set_int_set_int_mx801(int int1)
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
	
	public void set_long_mx8(long long1)
	{
		boolean isT = long1 == -0x8L;
		printAssert("set_long_mx8", isT);
	}
	
	public void set_long_xf(long long1)
	{
		boolean isT = long1 == 0xf;
		printAssert("set_long_xf", isT);
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

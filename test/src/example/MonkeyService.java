package example;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
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
	
	public Monkey get_monkey()
	{
		Monkey monkey1 = new Monkey();
		monkey1.setName("金玉彬");
		monkey1.setAge(18);
		
		return monkey1;
	}
	
	public Monkey get_null()
	{
		return null;
	}
	
	public boolean get_true()
	{
		return true;
	}
	
	public boolean get_false()
	{
		return false;
	}
	
	public int get_int()
	{
		return 300;
	}
	
	public long get_long()
	{
		return 9876543210L;
	}
	
	public long get_wlong()
	{
		return 59L;
	}
	
	public double get_double()
	{
		return 12.25;
	}
	
	public Date get_date()
	{
		return new Date();
	}
	
	public String get_string()
	{
		return "金玉彬";
	}
	
	public String get_hstring()
	{
		String str = get_string();
		return str;
	}
	
	public String[] get_list()
	{
		String[] list = {"a", "b", "c"};
		return list;
	}
	
	public ArrayList<String[]> get_rlist()
	{
		ArrayList<String[]> arr = new ArrayList<String[]>();
		String[] l = get_list();
		arr.add(l);
		arr.add(l);
		return arr;
	}

	public Map<String, Integer> get_map()
	{
		Map<String, Integer> m = new HashMap<String, Integer>();
		m.put("a", 1);
		m.put("b", 2);
		return m;
	}
	
	public ArrayList<Map<String, Integer>> get_rmap()
	{
		ArrayList<Map<String, Integer>> arr = new ArrayList<Map<String, Integer>>();
		Map<String, Integer> m = get_map();
		arr.add(m);
		arr.add(m);
		return arr;
	}
	
	public byte[] get_binary()
	{
		byte[] b = {};
		return b;
	}
	
	public byte[] get_hbinary()
	{
		return get_binary();
	}

	
	public void set_null(Object obj)
	{
		Object _null = null;
		if(_null == obj)
		{
			System.out.print("set_null.");
		}
		else
		{
			System.out.println(obj);
		}
		return;
	}
	
	public void set_true(boolean true1)
	{
		boolean _true = true;
		if(_true == true1)
		{
			System.out.print("set_true.");
		}
		else
		{
			System.out.println(true1);
		}
		return;
	}
	
	public void set_false(boolean false1)
	{
		boolean _false = false;
		if(_false == false1)
		{
			System.out.print("set_false.");
		}
		else
		{
			System.out.println(false1);
		}
		System.out.println("set_false " + false1);
		return;
	}
	
	public void set_int(int int1)
	{
		int _int = int1;
		
		System.out.println("set_int " + int1);
		return;
	}
	
	public void set_long(long long1)
	{
		System.out.println("min " + Long.MIN_VALUE);
		System.out.println("max " + Long.MAX_VALUE);
		System.out.println("set_long " + long1);
		return;
	}
	
	public void set_float(float float1)
	{
		System.out.println("set_float " + float1);
		return;
	}
	
	public void set_double(double double1)
	{
		System.out.println("set_double " + double1);
		return;
	}
	
	public void set_date(Date date1)
	{
		System.out.println("set_date " + date1);
		return;
	}
	
	public void set_string(String string1)
	{
		int len = string1.length();
		String str = "";
		if(len <= 31)
		{
			str = string1;
		}
		else
		{
			str = string1.substring(0, 32);
		}
			
		System.out.println("set_string " + string1.length() + " " + str);
		return;
	}
	
	public void set_list(int[] list1)
	{
		System.out.println("set_list " + list1.length);
		for (int int1 : list1) {
			System.out.print("  " + int1);
		}
		return;
	}
	
	public void set_map(Map<String, Object> map1)
	{
		System.out.println("set_map " + map1);
		return;
	}
	
	public void set_map_list_monkey_map_list_monkey(Map<String, Object> map1, int[] list1, Monkey monkey1, 
			Map<String, Object> map2, int[] list2, Monkey monkey2)
	{
		System.out.println("set_map_list_object_map_list_object");
		System.out.println(map1 + " " + map2);
		for (int int1 : list1) {
			System.out.print("  " + int1);
		}
		for (int int2 : list2) {
			System.out.print("  " + int2);
		}
		System.out.println("  " + monkey1.name + ": " + monkey1.age + " " + monkey2.name + ": " + monkey2.age);
		return;
	}
	
	public void set_bin(byte[] bin1)
	{
		System.out.println("set_bin " + bin1.length);
		return;
	}
	
	public void set_monkey_monkey(Monkey monkey1, Monkey monkey2)
	{
		System.out.println("  " + monkey1.name + ": " + monkey1.age + " " + monkey2.name + ": " + monkey2.age);
	}
	
	public void set_monkeys(ArrayList<Monkey> monkeys)
	{
		System.out.println("set_monkeys " + monkeys.size());
		for (Monkey monkey : monkeys) {
			System.out.println("  " + monkey.name + ": " + monkey.age);
		}
	}
	
}

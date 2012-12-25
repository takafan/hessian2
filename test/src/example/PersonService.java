package example;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.servlet.ServletContextHandler;
import org.eclipse.jetty.servlet.ServletHolder;

import com.caucho.hessian.server.HessianServlet;

public class PersonService extends HessianServlet implements IPersonService {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	
	public static void main(String[] args) throws Exception {
        Server server = new Server(9001);
        ServletContextHandler context = new ServletContextHandler(
        ServletContextHandler.SESSIONS);
        server.setHandler(context);
        ServletHolder servletHolder = new ServletHolder(new PersonService());
        context.addServlet(servletHolder, "/person");
        server.start();
        server.join(); 

    }
	
	public Person get_person()
	{
		Person person1 = new Person();
		person1.setName("½ðÓñ±ò");
		person1.setAge(18);
		
		return person1;
	}
	
	public Person get_null()
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
		return "½ðÓñ±ò";
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
	
	public void multi_set(Person person, 
			Person[] personlist,
			Map<Integer, Person> personmap,
			Object null1,
			boolean true1,
			boolean false1,
			int int1,
			long wlong1,
			long long1,
			double double1,
			Date date1,
			String str1,
			String hstr1,
			String[] list1,
			String[] list1r,
			ArrayList<ArrayList<String>> rlist1,
			Map<String, Integer> map1,
			Map<String, Integer> map1r,
			ArrayList<Map<String, Integer>> rmap1,
			byte[] bin1,
			byte[] hbin1)
	{
		System.out.println("true1 " + true1);
		System.out.println("false1 " + false1);
		System.out.println("int1 " + int1);
		System.out.println("long1 " + long1);
		System.out.println("wlong1 " + wlong1);
		System.out.println("double1 " + double1);
		System.out.println("date1 " + date1);
		System.out.println("str1 " + str1);
		System.out.println("person " + person);
		System.out.println("list1 " + list1.length);
		for (String str : list1) {
			System.out.println("  " + str);
		}
		System.out.println("list2 " + list1r.length);
		
		System.out.println("map1 " + map1.size());
		for(Map.Entry<String, Integer> e: map1.entrySet()){
			System.out.println("  " + e.getKey() + ": " + e.getValue());
		}
		
		return;
	}
	
	
	public void set_null(Object obj)
	{
		System.out.println("set_null " + obj);
		return;
	}
	
	public void set_true(boolean true1)
	{
		System.out.println("set_true " + true1);
		return;
	}
	
	public void set_false(boolean false1)
	{
		System.out.println("set_false " + false1);
		return;
	}
	
	public void set_int(int int1)
	{
		System.out.println("set_int " + int1);
		return;
	}
	
	public void set_long(long long1)
	{
		System.out.println("set_long " + long1);
		return;
	}
	
	public void set_wlong(long wlong1)
	{
		System.out.println("set_wlong " + wlong1);
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
		System.out.println("set_string " + string1);
		return;
	}
	
	public void set_hstring(String hstr1)
	{
		System.out.println("set_hstring " + hstr1.length());
		return;
	}
	
	public void set_list(String[] list1)
	{
		System.out.println("set_list " + list1.length);
		for (String str : list1) {
			System.out.println("  " + str);
		}
		return;
	}
	
	public void set_map(Map<String, Integer> map1)
	{
		System.out.println("set_map " + map1);
		return;
	}
	
	public void set_bin(byte[] bin1)
	{
		System.out.println("set_bin " + bin1.length);
		return;
	}
	
	public void set_person(Person person)
	{
		System.out.print("  " + person.name + ": " + person.age);
	}
	
}

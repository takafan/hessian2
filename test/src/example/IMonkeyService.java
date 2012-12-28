package example;

import java.util.ArrayList;
import java.util.Date;
import java.util.Map;

public interface IMonkeyService {
	public Monkey get_monkey();
	public Object get_null();
	public boolean get_true();
	public boolean get_false();
	public int get_int();
	public long get_wlong();
	public long get_long();
	public double get_double();
	public Date get_date();
	public String get_string();
	public String get_hstring();
	public String[] get_list();
	public ArrayList<String[]> get_rlist();
	public Map<String, Integer> get_map();
	public ArrayList<Map<String, Integer>> get_rmap();
	public byte[] get_binary();
	public byte[] get_hbinary();
	public void multi_set(Monkey person, 
			Monkey[] personlist,
			Map<Integer, Monkey> personmap,
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
			byte[] hbin1);
	
	public void set_null(Object obj);
	public void set_true(boolean true1);
	public void set_false(boolean false1);
	public void set_int(int int1);
	public void set_long(long long1);
	public void set_wlong(long wlong1);
	public void set_double(double double1);
	public void set_date(Date date1);
	public void set_string(String str1);
	public void set_hstring(String hstr1);
	public void set_list(int[] list1);
	public void set_list_list(int[] list1, int[] list2);
	public void set_map(Map<String, Integer> map1);
	public void set_map_map(Map<String, Integer> map1, Map<String, Integer> map2);
	public void set_bin(byte[] bin1);
	public void set_monkey(Monkey monkey1);
	public void set_monkey_monkey(Monkey monkey1, Monkey monkey2);
	
}

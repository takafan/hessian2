package example;

import java.util.ArrayList;
import java.util.Date;
import java.util.Map;

public interface IRemotePersonService {
	public Person get_person();
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
	public ArrayList<ArrayList<String>> get_rlist();
	public Map<String, Integer> get_map();
	public ArrayList<Map<String, Integer>> get_rmap();
	public byte[] get_binary();
	public byte[] get_hbinary();
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
			byte[] hbin1);
}

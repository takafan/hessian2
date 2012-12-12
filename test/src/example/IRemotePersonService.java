package example;

import java.util.ArrayList;
import java.util.Date;
import java.util.Map;

public interface IRemotePersonService {
	public Person get_person();
	public Object get_nil();
	public boolean get_true();
	public boolean get_false();
	public int get_fixnum();
	public long get_long();
	public long get_bignum();
	public double get_float();
	public Date get_time();
	public String get_string();
	public String get_huge_string();
	public String[] get_array();
	public ArrayList<ArrayList<String>> get_array_refer();
	public Map<String, Integer> get_hash();
	public ArrayList<Map<String, Integer>> get_hash_refer();
	public byte[] get_binary();
	public byte[] get_huge_binary();
	public void multi_set(Person person, 
			Object nil1,
			boolean true1,
			boolean false1,
			int int1,
			long long1,
			double double1,
			Date date1,
			String str1,
			String hstr1,
			String[] arr1,
			ArrayList<ArrayList<String>> rarr1,
			Map<String, Integer> map1,
			ArrayList<Map<String, Integer>> rmap1,
			byte[] bin1,
			byte[] hbin1);
	
}

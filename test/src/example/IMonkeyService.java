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
	
	public void set_string_0(String str1);
	public void set_string_31(String str1);
	public void set_string_31u(String str1);
	public void set_bin_0(byte[] bin1);
	public void set_bin_15(byte[] bin1);
	public void set_string_1023(String str1);
	public void set_string_1023u(String str1);
	public void set_bin_1023(byte[] bin1);
	public void set_long_3octetmin(long long1);
	public void set_long_3octetmax(long long1);
	public void set_lighthouse(byte[] bin1); //561276
	public void set_bin_1024(byte[] bin1);
	public void set_bin_x8000(byte[] bin1);
	public void set_monkey_monkey_t(Monkey monkey1, Monkey monkey2);
	public void set_monkey_monkey_c(Monkey monkey1, Monkey monkey2);
	public void set_monkey_monkey(Monkey monkey1, Monkey monkey2);
	public void set_double_min(double double1);
	public void set_double_max(double double1);
	public void set_false(boolean false1);
	public void set_map_h(Map<String, Object> map1);
	public void set_int_32bit_minm(int int1);
	public void set_int_32bit_min(int int1);
	public void set_int_32bit_maxm(int int1);
	public void set_int_32bit_max(int int1);
	public void set_date(Date date1);
	public void set_date_32bit(Date date1);
	public void set_long_64bit_min(long long1);
	public void set_long_64bit_max(long long1);
	public void set_map(Map<String, Object> map1);
	public void set_null(Object obj);
	public void set_monkeys(ArrayList<Monkey> monkeys);
	public void set_map_list_monkey_map_list_monkey(Map<String, Object> map1, int[] list1, Monkey monkey1, 
			Map<String, Object> map2, int[] list2, Monkey monkey2);
	public void set_string_nfc(String str1);
	public void set_string_nfcu(String str1);
	public void set_string_fc_min(String str1);
	public void set_string_fcu_min(String str1);
	public void set_string_fc_max(String str1);
	public void set_string_fcu_max(String str1);
	public void set_true(boolean true1);
	public void set_list_untyped(int[] list1);
	public void set_long_32bit_min(long long1);
	public void set_long_32bit_max(long long1);
	public void set_double_0(double double1);
	public void set_double_1(double double1);
	public void set_double_octet_min(double double1);
	public void set_double_octet_max(double double1);
	public void set_list_direct(int[] list1);
	public void set_int_octet_min(int int1);
	public void set_int_octet_max(int int1);
	public void set_int_2octet_min(int int1);
	public void set_int_2octet_max(int int1);
	public void set_int_3octet_min(int int1);
	public void set_int_3octet_max(int int1);
	
	
	
	
	
	
}

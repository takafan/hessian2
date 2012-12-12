import java.util.ArrayList;
import java.util.Date;
import java.util.Map;

import com.caucho.hessian.client.HessianProxyFactory;

import example.IRemotePersonService;
import example.Person;


public class HessianTest {
    public static void main(String[] args) throws Exception {
    	String url = "http://127.0.0.1:9292/person";

    	HessianProxyFactory factory = new HessianProxyFactory();
    	IRemotePersonService client = (IRemotePersonService) factory.create(IRemotePersonService.class, url);
    	
    	Person person = client.get_person();
    	Object null1 = client.get_nil();
    	boolean true1 = client.get_true();
    	boolean false1 = client.get_false();
    	int int1 = client.get_fixnum();
    	long long1 = client.get_long();
    	long long2 = client.get_bignum();
    	double double1 = client.get_float();
    	Date date = client.get_time();
    	String str1 = client.get_string();
    	String hstr1 = client.get_huge_string();
    	String[] arr1 = client.get_array();
    	ArrayList<ArrayList<String>> harr1 = client.get_array_refer();
    	Map<String, Integer> map1 = client.get_hash();
    	ArrayList<Map<String, Integer>> rmap1 = client.get_hash_refer();
    	byte[] bin1 = client.get_binary();
    	byte[] hbin1 = client.get_huge_binary();
    	
    	System.out.println("get_person: ");
    	System.out.print("  " + person.getName() + ": " + person.getAge());
    	System.out.println("get_nil: " + null1);
    	System.out.println("get_true: " + true1);
    	System.out.println("get_false: " + false1);
    	System.out.println("get_fixnum: " + int1);
    	System.out.println("get_long: " + long1);
    	System.out.println("get_bignum: " + long2);
    	System.out.println("get_float: " + double1);
    	System.out.println("get_time: " + date);
    	System.out.println("get_string: " + str1);
    	System.out.println("get_huge_string: " + hstr1.length());
    	System.out.println("get_array: ");
    	for (String str : arr1) {
			System.out.print("  " + str);
		}
    	System.out.println("get_array_refer: ");
    	for (ArrayList<String> arr : harr1) {
    		for (String str : arr) {
    			System.out.print("  " + str);
    		}
		}
    	System.out.println("get_hash: " + map1);
    	System.out.println("get_hash_refer: ");
    	for (Map<String, Integer> map : rmap1) {
    		System.out.print("  " + map);
		}
    	System.out.println("get_binary: " + bin1);
    	System.out.println("get_huge_binary: " + hbin1.length);
    	
    	client.multi_set(person, null1, true1, false1, int1, long2, double1, new Date(), str1, hstr1, arr1, harr1, map1, rmap1, bin1, hbin1);
    }
}

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
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
        Object null1 = client.get_null();
        boolean true1 = client.get_true();
        boolean false1 = client.get_false();
        int int1 = client.get_int();
        long wlong1 = client.get_wlong();
        long long1 = client.get_long();
        double double1 = client.get_double();
        Date date = client.get_date();
        String str1 = client.get_string();
        String hstr1 = client.get_hstring();
        String[] list1 = client.get_list();
        ArrayList<ArrayList<String>> rlist1 = client.get_rlist();
        Map<String, Integer> map1 = client.get_map();
        ArrayList<Map<String, Integer>> rmap1 = client.get_rmap();
        byte[] bin1 = client.get_binary();
        byte[] hbin1 = client.get_hbinary();
        
        System.out.println("get_person: ");
        System.out.print("  " + person.name + ": " + person.age);
        System.out.println("get_null: " + null1);
        System.out.println("get_true: " + true1);
        System.out.println("get_false: " + false1);
        System.out.println("get_int: " + int1);
        System.out.println("get_wlong: " + wlong1);
        System.out.println("get_long: " + long1);
        System.out.println("get_double: " + double1);
        System.out.println("get_date: " + date);
        System.out.println("get_string: " + str1);
        System.out.println("get_hstring: " + hstr1.length());
        System.out.println("get_list: ");
        for (String str : list1) {
            System.out.print("  " + str);
        }
        System.out.println("get_rlist: ");
        for (ArrayList<String> arr : rlist1) {
            for (String str : arr) {
                System.out.print("  " + str);
            }
        }
        System.out.println("get_map: " + map1);
        System.out.println("get_rmap: ");
        for (Map<String, Integer> map : rmap1) {
            System.out.print("  " + map);
        }
        System.out.println("get_binary: " + bin1);
        System.out.println("get_hbinary: " + hbin1.length);
        
        Map<Integer, Person> personmap = new HashMap<Integer, Person>();
        personmap.put(1, person);
        personmap.put(2, person);
        
        client.multi_set(person,
                new Person[]{person, person},
                personmap,
                null1, 
                true1, 
                false1, 
                int1, 
                wlong1, 
                long1, 
                double1, 
                new Date(), 
                str1, 
                hstr1, 
                list1, 
                list1, 
                rlist1, 
                map1,
                map1,
                rmap1, 
                bin1, 
                hbin1);
    }
}

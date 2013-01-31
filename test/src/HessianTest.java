import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import com.caucho.hessian.client.HessianProxyFactory;

import example.IMonkeyService;
import example.Monkey;


public class HessianTest {
    public static void main(String[] args) throws Exception {
        String url = "http://127.0.0.1:9292/monkey";

        HessianProxyFactory factory = new HessianProxyFactory();
        IMonkeyService client = (IMonkeyService) factory.create(IMonkeyService.class, url);

    }
}

alias :a#{type} :#{type}
         def #{type}(options = {}, &blk)
          puts "#{type}"
           f = Fiber.current

           conn = setup_request(:#{type}, options, &blk)
           if conn.error.nil?
             conn.callback { f.resume(conn) }
             conn.errback  { f.resume(conn) }

             Fiber.yield
           else
             conn
           end
         end
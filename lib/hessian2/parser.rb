require 'hessian2/fault'

module Hessian2
  module Parser
    # def parse(data)
    #   rets, vrefs, crefs, trefs = [], [], [], []
    #   until data.empty?
    #     rets << parse_object(data, vrefs, crefs, trefs)
    #   end
    #   rets.size == 1 ? rets.first : rets
    # end

    def parse(data)
      t = data.slice!(0)
      when 'H' # version
        data.slice!(0, 2)
        parse(data)
      when 'R' # reply
        parse_object(data)
      when 'C' # call
        args = []
        method = parse_object(data)
        parse(data).times do
          args << parse_object(data)
        end
        method, *args
      when 'F' # fault
        fault = parse_object(data)
        code, message = fault['code'], fault['message']
        raise Fault.new, code == 'RuntimeError' ? message : "#{code} - #{message}"
      else
        raise Fault.new, 'it\'s me http://hessian.caucho.com/doc/hessian-ws.html#anchor3'
      end
    end

    private
    def parse_object(data, refs = [], crefs = [], trefs = [])
      t = data.slice!(0)
      case t
      when 'N' # null
        nil
      when 'T' # true
        true
      when 'F' # false
        false
      when 'I' # int
        data.slice!(0, 4).unpack('l>')[0] 
      when 'L' # long
        data.slice!(0, 8).unpack('q>')[0] 
      when 'D' # double
        data.slice!(0, 8).unpack('G')[0] 
      when 'd' # date
        val = data.slice!(0, 8).unpack('Q>')[0]
        Time.at(val / 1000, val % 1000 * 1000)
      when 'S', 's', 'X', 'x' # string, xml
        t0 = Time.new
        len = data.slice!(0, 2).unpack('n')[0]
        chunk = data.unpack("U#{len}")
        chunks << chunk
        data.slice!(0, chunk.pack('U*').bytesize)
        
        if 'sx'.include?(t)
          @@s_time += 1
          parse_object(data, refs, chunks)
        else
          str = chunks.flatten.pack('U*')
          chunks.clear
          @@S_time += 1
          str
        end
      when 'B', 'b' # binary
        len = data.slice!(0, 2).unpack('n')[0]
        chunk = data.slice!(0, len)
        chunks << chunk
        
        if t == 'b'
          parse_object(data, refs, chunks)
        else
          str = chunks.join
          chunks.clear
          str
        end
      when 'V' # list
        data.slice!(0, 3 + data.unpack('an')[1]) if data[0] == 't'
        data.slice!(0, 5) if data[0] == 'l'
        refs << (list = [])
        list << parse_object(data, refs) while data[0] != 'z'
        data.slice!(0)
        list
      when 'M' # map
        if data[0] == 't'
          puts data.slice!(0, 3 + data.unpack('an')[1])
        end
        refs << (map = {})
        map[parse_object(data, refs)] = parse_object(data, refs) while data[0] != 'z'
        data.slice!(0)
        map
      when 'R' # ref
        refs[data.slice!(0, 4).unpack('N')[0]]
      else
        raise Fault.new, 'it\'s me http://hessian.caucho.com/doc/hessian-serialization.html#anchor3'
      end
    end

    

  end 
end



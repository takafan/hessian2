module Hessian2
  module HessianParser

    def parse(data, refs = [], chunks = [])
      t = data.slice!(0)
      case t
      when 'r' # reply
        data.slice!(0, 2)
        parse(data)
      when 'f' # fault
        parse(data)
        code = parse(data)
        parse(data)
        message = parse(data)
        raise HessianException.new, message
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
        len = data.slice!(0, 2).unpack('n')[0]

        chunk = data.unpack("U#{len}")
        chunks << chunk
        data.slice!(0, chunk.pack('U*').bytesize)
        
        if 'sx'.include?(t)
          parse(data, refs, chunks)
        else
          chunks.flatten.pack('U*')
        end
      when 'B', 'b' # binary
        len = data.slice!(0, 2).unpack('n')[0]

        chunk = data.slice!(0, len)
        chunks << chunk
        
        if t == 'b'
          parse(data, refs, chunks)
        else
          chunks.flatten 
        end
      when 'V' # list
        data.slice!(0, 3 + data.unpack('an')[1]) if data[0] == 't'
        data.slice!(0, 5) if data[0] == 'l'
        refs << (list = [])
        list << parse(data, refs) while data[0] != 'z'
        data.slice!(0)
        list
      when 'M' # map
        data.slice!(0, 3 + data.unpack('an')[1]) if data[0] == 't'
        refs << (map = {})
        map[parse(data, refs)] = parse(data, refs) while data[0] != 'z'
        data.slice!(0)
        map
      when 'R' # ref
        refs[data.slice!(0, 4).unpack('N')[0]]
      else
        raise HessianException.new, "Invalid type: '#{t}'"
      end
    end

  end 
end

require File.expand_path('../spec_helper', __FILE__)

module Hessian2
  describe Writer do
    context "when object" do
      hash = { id: nil, born_at: Time.new(2009, 5, 8), name: '大鸡', price: 99.99 }

      it "should write object type definition ('C') ::= 'C' string int string* and object with direct type ::= [x60-x6f] value*" do
        [ 'Monkey', 'AnotherMonkey' ].each do |klass|
          bin = Hessian2.write(Kernel.const_get(klass).new(hash))

          bytes = bin.each_byte
          expect([ bytes.next ].pack('C')).to eq('C')
          expect(Hessian2.parse_string(bytes)).to eq(klass)
          expect(Hessian2.parse_int(bytes)).to eq(4)
          4.times{ Hessian2.parse_string(bytes) }
          expect(bytes.next - 0x60).to eq(0)
          monkey = Hessian2.parse(bin)
          expect([ monkey.born_at, monkey.name, monkey.price ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
        end

        [ hash, Monkey.new(hash), AnotherMonkey.new(hash) ].each do |val|
          bin = Hessian2.write(Hessian2::ClassWrapper.new('com.sun.java.Monkey', val))

          bytes = bin.each_byte
          expect([ bytes.next ].pack('C')).to eq('C')
          expect(Hessian2.parse_string(bytes)).to eq('com.sun.java.Monkey')
          expect(Hessian2.parse_int(bytes)).to eq(4)
          4.times{ Hessian2.parse_string(bytes) }
          expect(bytes.next - 0x60).to eq(0)
          monkey = Hessian2.parse(bin)
          expect([ monkey.born_at, monkey.name, monkey.price ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
        end

        bin = Hessian2.write(Hessian2::ClassWrapper.new('com.sun.java.Monkey', nil))
        expect(bin).to eq('N')
        expect(Hessian2.parse(bin)).to eq(nil)
      end

      # it "should write object instance ('O') ::= 'O' int value*" do
      #   bin = Hessian2.write(hash)

      #   bytes = bin.each_byte
      #   expect(bin[0]).to eq('H')
      #   expect(bin[-1]).to eq('Z')
      #   map = Hessian2.parse(bin)
      #   expect([ map['born_at'], map['name'], map['price'] ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
      #   map2 = Hessian2.parse(bin, nil, symbolize_keys: true)
      #   puts map2.inspect
      #   expect(map2).to eq(hash)
      # end

    end
  end
end

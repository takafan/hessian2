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

      end

      it "should write object instance ('O') ::= 'O' int value*" do
        arr = []
        17.times do |i|
          arr << Hessian2::ClassWrapper.new("com.sun.java.Monkey#{i}", hash)
        end
        bin = Hessian2.write(arr)

        bytes = bin.each_byte

        # skip x58 int
        bytes.next
        Hessian2.parse_int(bytes)

        # skip top 16
        16.times do
          bytes.next
          Hessian2.parse_string(bytes)
          Hessian2.parse_int(bytes)
          4.times{ Hessian2.parse_string(bytes) }
          bytes.next
          4.times{ Hessian2.parse_bytes(bytes) }
        end

        # skip 17th class definition
        bytes.next
        Hessian2.parse_string(bytes)
        Hessian2.parse_int(bytes)
        4.times{ Hessian2.parse_string(bytes) }

        expect([ bytes.next ].pack('C')).to eq('O')
        expect(Hessian2.parse_int(bytes)).to eq(16)

        monkeys = Hessian2.parse(bin)
        expect(monkeys.size).to eq(17)
        monkeys.each do |monkey|
          expect([ monkey.born_at, monkey.name, monkey.price ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
        end
      end

    end
  end
end

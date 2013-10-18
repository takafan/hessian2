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
          _monkey = Hessian2.parse(bin)
          expect([ _monkey.born_at, _monkey.name, _monkey.price ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
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

        _monkeys = Hessian2.parse(bin)
        expect(_monkeys.size).to eq(17)
        _monkeys.each do |_monkey|
          expect([ _monkey.born_at, _monkey.name, _monkey.price ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
        end
      end

      it "should write ActiveRecord::Relation" do
        val = Monkey.where(true).limit(2)
        bin = Hessian2.write(val)

        bytes = bin.each_byte
        expect(bytes.next - 0x78).to eq(val.size)

        born_at = Time.new(1989, 5, 8)
        Hessian2.parse(bin).each_with_index do |_monkey, i|
          expect([ _monkey.id, _monkey.name, _monkey.price, _monkey.born_at ]).to eq([ i + 1, "#{i}号猴", 0.25 * i, born_at + 86400 * i ])
        end
      end

    end
  end
end

require File.expand_path('../spec_helper', __FILE__)

module Hessian2
  describe ClassWrapper do
		hash = { id: nil, born_at: Time.new(2009, 5, 8), name: '大鸡', price: 99.99 }

		it "should raise error" do
			expect(lambda{ Hessian2::ClassWrapper.new('com.sun.java.Monkey') }).to raise_error
		end

		it "should wrap nil" do
			bin = Hessian2.write(Hessian2::ClassWrapper.new('com.sun.java.Monkey', nil))

			expect(bin).to eq('N')
			expect(Hessian2.parse(bin)).to eq(nil)
		end

		it "should wrap hash, monkey, another monkey" do
			bin = Hessian2.write(Hessian2::ClassWrapper.new('com.sun.java.Monkey', hash))
			
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
		end

		it "should wrap array" do
			arr = [nil, hash, Monkey.new(hash), AnotherMonkey.new(hash)]
			bin = Hessian2.write(Hessian2::ClassWrapper.new('[com.sun.java.Monkey', arr))
			
			monkey1, monkey2, monkey3, monkey4 = Hessian2.parse(bin)
			expect(monkey1).to eq(nil)
			[ monkey2, monkey3, monkey4 ].each do |monkey|
				expect([ monkey.born_at, monkey.name, monkey.price ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
			end
			
		end
		
	end
end

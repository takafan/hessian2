require File.expand_path('../spec_helper', __FILE__)

module Hessian2
  describe ClassWrapper do
		hash = { id: nil, born_at: Time.new(2009, 5, 8), name: '大鸡', price: 99.99 }

		it "should raise error" do
			expect(lambda{ Hessian2::ClassWrapper.new('com.sun.java.Monkey') }).to raise_error
			expect(lambda{ Hessian2::ClassWrapper.new('com.sun.java.Monkey', 59) }).to raise_error
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
				_monkey = Hessian2.parse(bin)
				expect([ _monkey.born_at, _monkey.name, _monkey.price ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
			end
		end


		it "should wrap array" do
			arr = [nil, hash, Monkey.new(hash), AnotherMonkey.new(hash)]
			bin = Hessian2.write(Hessian2::ClassWrapper.new('[com.sun.java.Monkey', arr))
			
			_monkey1, _monkey2, _monkey3, _monkey4 = Hessian2.parse(bin)
			expect(_monkey1).to eq(nil)
			[ _monkey2, _monkey3, _monkey4 ].each do |_monkey|
				expect([ _monkey.born_at, _monkey.name, _monkey.price ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
			end
			
		end
		
	end
end

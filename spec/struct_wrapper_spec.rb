require File.expand_path('../spec_helper', __FILE__)

module Hessian2
  describe StructWrapper do
		hash = { id: nil, born_at: Time.new(2009, 5, 8), name: '大鸡', price: 99.99 }

		it "should raise error" do
			expect(lambda{ Hessian2::StructWrapper.new(MonkeyStruct) }).to raise_error
		end

		it "should wrap nil" do
			bin = Hessian2.write(Hessian2::StructWrapper.new(MonkeyStruct, nil))

			monkey = Hessian2.parse(bin, MonkeyStruct)
			expect(monkey).to eq(nil)
		end

		it "should wrap hash, monkey, another monkey" do
			[ MonkeyStruct, 'MonkeyStruct' ].each do |klass|
				[ hash, Monkey.new(hash), AnotherMonkey.new(hash) ].each do |val|
					bin = Hessian2.write(Hessian2::StructWrapper.new(klass, val))
					
					monkey = Hessian2.parse(bin, klass)
					expect([ monkey.born_at, monkey.name, monkey.price ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
				end
			end
		end

		it "should wrap array" do
			[ [MonkeyStruct], '[MonkeyStruct' ].each do |klass|
				arr = [ nil, hash, Monkey.new(hash), AnotherMonkey.new(hash) ]
				bin = Hessian2.write(Hessian2::StructWrapper.new(klass, arr))
				
				monkey, monkey2, monkey3, monkey4 = Hessian2.parse(bin, klass)
				expect([ monkey, monkey2.born_at, monkey2.name, monkey2.price, monkey3.born_at, monkey3.name, monkey3.price, monkey4.born_at, monkey4.name, monkey4.price ]).to eq([ nil, hash[:born_at], hash[:name], hash[:price], hash[:born_at], hash[:name], hash[:price], hash[:born_at], hash[:name], hash[:price] ])
			end
		end
		
	end
end

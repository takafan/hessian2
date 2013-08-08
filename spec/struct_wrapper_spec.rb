require File.expand_path('../spec_helper', __FILE__)

module Hessian2
  describe StructWrapper do
		hash = { born_at: Time.new(2005, 3, 4), name: '阿门', price: 59.59 }

		it "should raise error" do
			expect(lambda{ Hessian2::StructWrapper.new(MonkeyStruct) }).to raise_error
		end

		it "should wrap nil" do
			bin = Hessian2.write(Hessian2::StructWrapper.new(MonkeyStruct, nil))

			monkey = Hessian2.parse(bin, MonkeyStruct)
			expect(monkey).to eq(nil)
		end

		it "should wrap hash" do
			bin = Hessian2.write(Hessian2::StructWrapper.new(MonkeyStruct, hash))
			bin2 = Hessian2.write(Hessian2::StructWrapper.new('MonkeyStruct', hash))

			monkey = Hessian2.parse(bin, MonkeyStruct)
			monkey2 = Hessian2.parse(bin2, MonkeyStruct)
			expect([ monkey.born_at, monkey.name, monkey.price ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
			expect([ monkey2.born_at, monkey2.name, monkey2.price ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
		end

		it "should wrap monkey" do
			bin = Hessian2.write(Hessian2::StructWrapper.new(MonkeyStruct, Monkey.new(hash)))

			monkey = Hessian2.parse(bin, MonkeyStruct)
			expect([ monkey.born_at, monkey.name, monkey.price ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
		end

		it "should wrap another monkey" do
			bin = Hessian2.write(Hessian2::StructWrapper.new(MonkeyStruct, AnotherMonkey.new(hash)))

			monkey = Hessian2.parse(bin, MonkeyStruct)
			expect([ monkey.born_at, monkey.name, monkey.price ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
		end

		it "should wrap array" do
			bin = Hessian2.write(Hessian2::StructWrapper.new([MonkeyStruct], [nil, hash, Monkey.new(hash), AnotherMonkey.new(hash)]))
			bin2 = Hessian2.write(Hessian2::StructWrapper.new('[MonkeyStruct', [nil, hash, Monkey.new(hash), AnotherMonkey.new(hash)]))

			monkey, monkey2, monkey3, monkey4 = Hessian2.parse(bin, [MonkeyStruct])
			monkey5, monkey6, monkey7, monkey8 = Hessian2.parse(bin2, [MonkeyStruct])
			expect([ monkey, monkey2.born_at, monkey2.name, monkey2.price, monkey3.born_at, monkey3.name, monkey3.price, monkey4.born_at, monkey4.name, monkey4.price ]).to eq([ nil, hash[:born_at], hash[:name], hash[:price], hash[:born_at], hash[:name], hash[:price], hash[:born_at], hash[:name], hash[:price] ])
			expect([ monkey5, monkey6.born_at, monkey6.name, monkey6.price, monkey7.born_at, monkey7.name, monkey7.price, monkey8.born_at, monkey8.name, monkey8.price ]).to eq([ nil, hash[:born_at], hash[:name], hash[:price], hash[:born_at], hash[:name], hash[:price], hash[:born_at], hash[:name], hash[:price] ])
		end
		
	end
end

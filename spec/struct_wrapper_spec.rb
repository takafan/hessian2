require 'spec_helper'

module Hessian2
  describe StructWrapper do
		hash = { born_at: Time.new(2005, 3, 4), name: '阿门', price: 59.59 }

		it "should raise error" do
			expect(lambda{ Hessian2::StructWrapper.new(MonkeyStruct) }).to raise_error
		end

		it "should wrap nil" do
			bin = Hessian2.write(Hessian2::StructWrapper.new(MonkeyStruct, nil))

			_monkey = Hessian2.parse(bin, MonkeyStruct)
			expect(_monkey).to eq(nil)
		end

		it "should wrap hash" do
			bin = Hessian2.write(Hessian2::StructWrapper.new(MonkeyStruct, hash))
			bin2 = Hessian2.write(Hessian2::StructWrapper.new('MonkeyStruct', hash))

			_monkey = Hessian2.parse(bin, MonkeyStruct)
			_monkey2 = Hessian2.parse(bin2, MonkeyStruct)
			expect([ _monkey.born_at, _monkey.name, _monkey.price ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
			expect([ _monkey2.born_at, _monkey2.name, _monkey2.price ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
		end

		it "should wrap monkey" do
			bin = Hessian2.write(Hessian2::StructWrapper.new(MonkeyStruct, Monkey.new(hash)))

			_monkey = Hessian2.parse(bin, MonkeyStruct)
			expect([ _monkey.born_at, _monkey.name, _monkey.price ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
		end

		it "should wrap another monkey" do
			bin = Hessian2.write(Hessian2::StructWrapper.new(MonkeyStruct, AnotherMonkey.new(hash)))

			_monkey = Hessian2.parse(bin, MonkeyStruct)
			expect([ _monkey.born_at, _monkey.name, _monkey.price ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
		end

		it "should wrap array" do
			bin = Hessian2.write(Hessian2::StructWrapper.new([MonkeyStruct], [nil, hash, Monkey.new(hash), AnotherMonkey.new(hash)]))
			bin2 = Hessian2.write(Hessian2::StructWrapper.new('[MonkeyStruct', [nil, hash, Monkey.new(hash), AnotherMonkey.new(hash)]))

			_monkey, _monkey2, _monkey3, _monkey4 = Hessian2.parse(bin, [MonkeyStruct])
			_monkey5, _monkey6, _monkey7, _monkey8 = Hessian2.parse(bin2, [MonkeyStruct])
			expect([ _monkey, _monkey2.born_at, _monkey2.name, _monkey2.price, _monkey3.born_at, _monkey3.name, _monkey3.price, _monkey4.born_at, _monkey4.name, _monkey4.price ]).to eq([ nil, hash[:born_at], hash[:name], hash[:price], hash[:born_at], hash[:name], hash[:price], hash[:born_at], hash[:name], hash[:price] ])
			expect([ _monkey5, _monkey6.born_at, _monkey6.name, _monkey6.price, _monkey7.born_at, _monkey7.name, _monkey7.price, _monkey8.born_at, _monkey8.name, _monkey8.price ]).to eq([ nil, hash[:born_at], hash[:name], hash[:price], hash[:born_at], hash[:name], hash[:price], hash[:born_at], hash[:name], hash[:price] ])
		end
		
	end
end

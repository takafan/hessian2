require File.expand_path('../spec_helper', __FILE__)

module Hessian2
  describe StructWrapper do
		hash = { id: nil, born_at: Time.new(2009, 5, 8), name: '大鸡', price: 99.99 }
		
		# it "should raise error" do
		# 	expect(lambda{ Hessian2::StructWrapper.new(MonkeyStruct) }).to raise_error
		# end


		# it "should wrap nil" do
		# 	bin = Hessian2.write(Hessian2::StructWrapper.new(MonkeyStruct, nil))

		# 	_monkey = Hessian2.parse(bin, MonkeyStruct)
		# 	expect(_monkey).to eq(nil)
		# end


		# it "should wrap hash, monkey, another monkey" do
		# 	[ MonkeyStruct, 'MonkeyStruct' ].each do |klass|
		# 		[ hash, Monkey.new(hash), AnotherMonkey.new(hash) ].each do |val|
		# 			bin = Hessian2.write(Hessian2::StructWrapper.new(klass, val))
					
		# 			_monkey = Hessian2.parse(bin, klass)
		# 			expect([ _monkey.born_at, _monkey.name, _monkey.price ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
		# 		end
		# 	end
		# end


		it "should wrap array" do
			[ [MonkeyStruct], '[MonkeyStruct' ].each do |klass|
				arr = [ nil, hash, Monkey.new(hash), AnotherMonkey.new(hash) ]
				bin = Hessian2.write(Hessian2::StructWrapper.new(klass, arr))
				
				_monkey1, _monkey2, _monkey3, _monkey4 = Hessian2.parse(bin, klass, symbolize_keys: true)
				expect(_monkey1).to eq(nil)
				expect([ _monkey2[:born_at], _monkey2[:name], _monkey2[:price] ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
				[ _monkey3, _monkey4 ].each do |_monkey|
					expect([ _monkey.born_at, _monkey.name, _monkey.price ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
				end
			end
		end
		
	end
end

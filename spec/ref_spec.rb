require File.expand_path('../spec_helper', __FILE__)

module Hessian2
  describe Writer do
    context "when ref" do
      hash = { id: nil, born_at: Time.new(2009, 5, 8), name: '大鸡', price: 99.99 }

      it "should write reference to map/list/object - integer ('Q') ::= x51 int" do
        monkey = Monkey.new(hash)
        monkey2 = Hessian2::ClassWrapper.new("com.sun.java.Monkey", hash)
        monkeys = [ monkey, monkey2 ]
        arr = [ hash, monkey, monkey2, monkeys ] * 2
        
        bin = Hessian2.write(arr)

        _hash1, _monkey1, _monkey2, _monkeys1, _hash2, _monkey3, _monkey4, _monkeys2 = Hessian2.parse(bin, nil, symbolize_keys: true)

        [ _hash1, _hash2 ].each do |_hash|
          expect([ _hash[:born_at], _hash[:name], _hash[:price] ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
        end

        [ _monkey1, _monkey2, _monkey3, _monkey4 ].each do |_monkey|
          expect([ _monkey.born_at, _monkey.name, _monkey.price ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
        end

        [ _monkeys1, _monkeys2 ].each do |_monkeys|
          _monkeys.each do |_monkey|
            expect([ _monkey.born_at, _monkey.name, _monkey.price ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
          end
        end
        
      end

    end
  end
end

require File.expand_path('../spec_helper', __FILE__)

module Hessian2
  describe Writer do
    context "when ref" do
      hash1 = { id: nil, born_at: Time.new(2009, 5, 8), name: '大鸡', price: 99.99 }

      it "should write reference to map/list/object - integer ('Q') ::= x51 int" do
        monkey1 = Monkey.new(hash1)
        monkey2 = Hessian2::ClassWrapper.new("com.sun.java.Monkey", hash1)
        monkey3 = Hessian2::TypeWrapper.new("com.sun.java.Monkey", hash1)
        monkeys1 = [ monkey1, monkey2, monkey3 ]
        monkeys2 = Hessian2::ClassWrapper.new("[com.sun.java.Monkey", monkeys1)
        monkeys3 = Hessian2::TypeWrapper.new("[com.sun.java.Monkey", monkeys1)

        arr = [ hash1, monkey1, monkey2, monkey3, monkeys1, monkeys2, monkeys3 ] * 2
        
        bin = Hessian2.write(arr)

        _hash1, _monkey1, _monkey2, _monkey3, _monkeys1, _monkeys2, _monkeys3, \
        _hash1r, _monkey1r, _monkey2r, _monkey3r, _monkeys1r, _monkeys2r, _monkeys3r = Hessian2.parse(bin, nil, symbolize_keys: true)

        [ _hash1, _hash1r, _monkey3, _monkey3r ].each do |_hash|
          expect([ _hash[:born_at], _hash[:name], _hash[:price] ]).to eq([ hash1[:born_at], hash1[:name], hash1[:price] ])
        end

        [ _monkey1, _monkey2, _monkey1r, _monkey2r ].each do |_monkey|
          expect([ _monkey.born_at, _monkey.name, _monkey.price ]).to eq([ hash1[:born_at], hash1[:name], hash1[:price] ])
        end
        
        [ _monkeys1, _monkeys2, _monkeys3, _monkeys1r, _monkeys2r, _monkeys3r ].each do |_monkeys|
          [ _monkeys[0], _monkeys[1] ].each do |_monkey|
            expect([ _monkey.born_at, _monkey.name, _monkey.price ]).to eq([ hash1[:born_at], hash1[:name], hash1[:price] ])
          end
          last = _monkeys.last
          expect([ last[:born_at], last[:name], last[:price] ]).to eq([ hash1[:born_at], hash1[:name], hash1[:price] ])
        end

      end

    end
  end
end

require File.expand_path('../spec_helper', __FILE__)

module Hessian2
  describe Writer do
    context "when ref" do
      hash = { id: nil, born_at: Time.new(2009, 5, 8), name: '大鸡', price: 99.99 }

      it "should write reference to map/list/object - integer ('Q') ::= x51 int" do
        monkey = Monkey.new(hash)
        monkey2 = Hessian2::ClassWrapper.new("com.sun.java.Monkey", hash)
        monkey3 = Hessian2::TypeWrapper.new("com.sun.java.Monkey", hash)
        monkeys = [ monkey, monkey2, monkey3 ]
        monkeys2 = Hessian2::ClassWrapper.new("[com.sun.java.Monkey", monkeys)
        monkeys3 = Hessian2::TypeWrapper.new("[com.sun.java.Monkey", monkeys)

        arr = [ hash, monkey, monkey2, monkey3, monkeys, monkeys2, monkeys3 ] * 2
        
        bin = Hessian2.write(arr)

        _hash1, _monkey1, _monkey2, _monkey3, _monkeys1, _monkeys2, _monkeys3, _hash1r, _monkey1r, _monkey2r, _monkey3r, _monkeys1r, _monkeys2r, _monkeys3r = Hessian2.parse(bin, nil, symbolize_keys: true)

        # [ _hash1, _hash1r, _monkey3, _monkey3r ].each do |_hash|
        #   expect([ _hash[:born_at], _hash[:name], _hash[:price] ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
        # end

        # [ _monkey1, _monkey2, _monkey1r, _monkey2r ].each do |_monkey|
        #   expect([ _monkey.born_at, _monkey.name, _monkey.price ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
        # end

        puts _monkeys3r.inspect

        # [ _monkeys1, _monkeys2, _monkeys3, _monkeys1r, _monkeys2r, _monkeys3r ].each do |_monkeys|
        #   _monkeys[0, 2].each do |_monkey|
        #     expect([ _monkey.born_at, _monkey.name, _monkey.price ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
        #   end
        #   expect([ _monkeys.last[:born_at], _monkeys.last[:name], _monkeys.last[:price] ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
        # end
        
      end

    end
  end
end

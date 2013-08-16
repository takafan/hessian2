require File.expand_path('../spec_helper', __FILE__)

module Hessian2
  describe Writer do
    context "when map" do
      hash = { born_at: Time.new(2009, 5, 8), name: '大鸡', price: 99.99 }

      it "should write map with type ('M') ::= M type (value value)* Z" do
        type = 'Monkey'
        bin = Hessian2.write(Hessian2::TypeWrapper.new(type, hash))

        bytes = bin.each_byte
        expect([ bytes.next ].pack('C')).to eq('M')
        expect(Hessian2.parse_string(bytes)).to eq(type)
        map = Hessian2.parse(bin)
        expect([ map['born_at'], map['name'], map['price'] ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
        map2 = Hessian2.parse(bin, nil, symbolize_keys: true)
        expect(map2).to eq(hash)
      end


      it "should write untyped map ::= 'H' (value value)* 'Z'" do
        bin = Hessian2.write(hash)

        bytes = bin.each_byte
        expect(bin[0]).to eq('H')
        expect(bin[-1]).to eq('Z')
        map = Hessian2.parse(bin)
        expect([ map['born_at'], map['name'], map['price'] ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
        map2 = Hessian2.parse(bin, nil, symbolize_keys: true)
        puts map2.inspect
        expect(map2).to eq(hash)
      end

    end
  end
end

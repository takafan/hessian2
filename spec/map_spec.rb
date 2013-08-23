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
        _hash = Hessian2.parse(bin)
        expect([ _hash['born_at'], _hash['name'], _hash['price'] ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
        _hash2 = Hessian2.parse(bin, nil, symbolize_keys: true)
        expect(_hash2).to eq(hash)
      end


      it "should write untyped map ::= 'H' (value value)* 'Z'" do
        bin = Hessian2.write(hash)

        bytes = bin.each_byte
        expect(bin[0]).to eq('H')
        expect(bin[-1]).to eq('Z')
        _hash = Hessian2.parse(bin)
        expect([ _hash['born_at'], _hash['name'], _hash['price'] ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
        _hash2 = Hessian2.parse(bin, nil, symbolize_keys: true)
        expect(_hash2).to eq(hash)
      end

    end
  end
end

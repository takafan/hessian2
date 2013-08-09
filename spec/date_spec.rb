require File.expand_path('../spec_helper', __FILE__)

module Hessian2
  describe Writer do
    context "when date" do
      
      it "should write 32-bit UTC minute date ::= x4b b3 b2 b1 b0" do
        val = Time.new(2008, 8, 8, 8, 8)
        bin = Hessian2.write(val)

        expect(bin[0].unpack('C').first).to eq(0x4b)
        expect(Time.at(bin[1, 4].unpack('l>').first * 60)).to eq(val)
        expect(Hessian2.parse(bin)).to eq(val)
      end

      it "should write 64-bit UTC millisecond date ::= x4a b7 b6 b5 b4 b3 b2 b1 b0" do
        val = Time.new(2008, 8, 8, 8, 8, 8)
        bin = Hessian2.write(val)

        expect(bin[0].unpack('C').first).to eq(0x4a)
        _val = bin[1, 8].unpack('q>').first
        expect(Time.at(_val / 1000, _val % 1000 * 1000)).to eq(val)
        expect(Hessian2.parse(bin)).to eq(val)

        val2 = Time.at(946684800, 123456.789)
        bin2 = Hessian2.write(val2)

        expect(bin2[0].unpack('C').first).to eq(0x4a)
        _val2 = bin2[1, 8].unpack('Q>').first
        expect(Time.at(_val2 / 1000, _val2 % 1000 * 1000)).to eq(Time.at(val2.to_i, val2.usec / 1000 * 1000))
        expect(Hessian2.parse(bin2)).to eq(Time.at(val2.to_i, val2.usec / 1000 * 1000))

        val3 = Time.at(946684800.2)
        bin3 = Hessian2.write(val3)

        expect(bin3[0].unpack('C').first).to eq(0x4a)
        _val3 = bin3[1, 8].unpack('Q>').first
        expect(Time.at(_val3 / 1000, _val3 % 1000 * 1000)).to eq(Time.at(val3.to_i, val3.usec / 1000 * 1000))
        expect(Hessian2.parse(bin3)).to eq(Time.at(val3.to_i, val3.usec / 1000 * 1000))
      end

    end
  end
end

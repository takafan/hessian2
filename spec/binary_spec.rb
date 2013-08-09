require File.expand_path('../spec_helper', __FILE__)

module Hessian2
  describe Writer do
    context "when binary" do
      
      it "should write binary data length 0-15 ::= [x20-x2f] <binary-data>" do
        (0..15).to_a.each do |len|
          val = ['b' * len].pack('a*')
          bin = Hessian2.write(Hessian2::TypeWrapper.new(:bin, val))

          expect(bin[0].unpack('C').first - 0x20).to eq(val.size)
          expect(bin.size).to eq(1 + val.size)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end

      it "should write binary data length 0-1023 ::= [x34-x37] <binary-data>" do
        [ 16, 256, 512, 1023 ].each do |len|
          val = ['b' * len].pack('a*')
          bin = Hessian2.write(Hessian2::TypeWrapper.new(:bin, val))

          b1, b0 = bin[0, 2].unpack('CC')
          expect(256 * (b1 - 0x34) + b0).to eq(val.size)
          expect(bin.size).to eq(2 + val.size)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end

      it "should write 8-bit binary data non-final chunk ('A') ::= x41 b1 b0 <binary-data> and 8-bit binary data final chunk ('B') ::= 'B' b1 b0 <binary-data>" do
        val = IO.binread(File.expand_path("../Lighthouse.jpg", __FILE__))
        bin = Hessian2.write(Hessian2::TypeWrapper.new(:bin, val))
        chunks = val.size / 0x8000

        chunks.times do |c|
          i = c * 0x8003
          expect(bin[i]).to eq('A')
          expect(bin[i + 1, 2].unpack('n').first).to eq(0x8000)
        end

        i = chunks * 0x8003
        expect(bin[i]).to eq('B')
        expect(bin[i + 1, 2].unpack('n').first).to eq(val.size - 0x8000 * chunks)
        expect(Hessian2.parse(bin)).to eq(val)
      end

    end
  end
end

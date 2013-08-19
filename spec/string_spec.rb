require File.expand_path('../spec_helper', __FILE__)

module Hessian2
  describe Writer do
    context "when string" do
      
      it "should write utf-8 string length 0-31 ::= [x00-x1f] <utf8-data>" do
        (0..31).each do |len|
          val = '啦' * len
          bin = Hessian2.write(val)

          expect(bin[0].unpack('C').first).to eq(val.size)
          expect(bin[1..-1]).to eq(val.b)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end


      it "should write utf-8 string length 0-1023 ::= [x30-x33] b0 <utf8-data>" do
        [ 33, 256, 512, 1023 ].each do |len|
          val = '啦' * len
          bin = Hessian2.write(val)

          b1, b0 = bin[0, 2].unpack('CC')
          expect(256 * (b1 - 0x30) + b0).to eq(val.size)
          expect(bin[2..-1]).to eq(val.b)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end

      it "should write utf-8 string final chunk ('S') ::= S b1 b0 <utf8-data>" do
        val = '啦' * 0x400
        bin = Hessian2.write(val)
        
        expect(bin[0]).to eq('S')
        expect(bin[1, 2].unpack('n').first).to eq(0x400)
        expect(Hessian2.parse(bin)).to eq(val)
      end


      it "should write utf-8 string non-final chunk ('R') ::= x52 b1 b0 <utf8-data>" do
        val = '啦' * 0x10400
        bin = Hessian2.write(val)

        chunks = val.size / 0x8000
        i = 0

        chunks.times do |c|
          expect(bin[i]).to eq('R')
          expect(bin[i + 1, 2].unpack('n').first).to eq(0x8000)
          i += (3 + val[c * 0x8000, 0x8000].bytesize)
        end
        
        expect(bin[i]).to eq('S')
        expect(bin[i + 1, 2].unpack('n').first).to eq(val.size - 0x8000 * chunks)
        expect(Hessian2.parse(bin)).to eq(val)
      end

    end
  end
end

require File.expand_path('../spec_helper', __FILE__)

module Hessian2
  describe Writer do
    context "when binary" do
      
      it "should write binary data length 0-15" do
        [ 0, 15 ].each do |len|
          val = ['b' * len].pack('a*')
          bin = Hessian2.write(Hessian2::TypeWrapper.new(:bin, val))

          expect(bin[0].unpack('C').first - 0x20).to eq(val.size)
          expect(bin.size).to eq(1 + val.size)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end

      it "should write binary data length 0-1023" do
        [ 16, 1023 ].each do |len|
          val = ['b' * len].pack('a*')
          bin = Hessian2.write(Hessian2::TypeWrapper.new(:bin, val))

          b1, b0 = bin[0, 2].unpack('CC')
          expect(256 * (b1 - 0x34) + b0).to eq(val.size)
          expect(bin.size).to eq(2 + val.size)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end

      it "should write binary" do
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

require File.expand_path('../spec_helper', __FILE__)

module Hessian2
  describe Writer do
    context "when double" do

      it "should write infinite" do
        val = Float::INFINITY
        bin = Hessian2.write(val)

        expect(bin[0]).to eq('D')
        expect(bin.bytesize).to eq(9)
        expect(Hessian2.parse(bin)).to eq(val)
      end

      it "should write -infinite" do
        val = -Float::INFINITY
        bin = Hessian2.write(val)

        expect(bin[0]).to eq('D')
        expect(bin.bytesize).to eq(9)
        expect(Hessian2.parse(bin)).to eq(val)
      end

      it "should write nan" do
        val = Float::NAN
        bin = Hessian2.write(val)

        expect(bin[0]).to eq('D')
        expect(bin.bytesize).to eq(9)
        expect(Hessian2.parse(bin).nan?).to eq(true)
      end

      it "should write double 0.0" do
        bin = Hessian2.write(0.0)

        expect(bin.unpack('C').first).to eq(0x5b)
        expect(Hessian2.parse(bin)).to eq(0)
      end

      it "should write double 1.0" do
        bin = Hessian2.write(1.0)

        expect(bin.unpack('C').first).to eq(0x5c)
        expect(Hessian2.parse(bin)).to eq(1)
      end

      it "should write double represented as byte (-128.0 to 127.0)" do
        [ -128.0, 127.0 ].each do |val|
          bin = Hessian2.write(val)

          expect(bin[0].unpack('C').first).to eq(0x5d)
          expect(bin.bytesize).to eq(2)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end

      it "should write double represented as short (-32768.0 to 327676.0)" do
        [ -32768.0, 32767.0, -129.0, 128.0 ].each do |val|
          bin = Hessian2.write(val)

          expect(bin[0].unpack('C').first).to eq(0x5e)
          expect(bin.bytesize).to eq(3)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end

      it "should write double represented as float" do
        [ -123.456, 123.456 ].each do |val|
          bin = Hessian2.write(val)

          expect(bin[0].unpack('C').first).to eq(0x5f)
          expect(bin.bytesize).to eq(5)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end

      it "should write 64-bit IEEE encoded double ('D')" do
        [ 4.9E-324, 1.7976931348623157E308 ].each do |val|
          bin = Hessian2.write(val)
          
          expect(bin[0]).to eq('D')
          expect(bin.bytesize).to eq(9)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end

    end
  end
end

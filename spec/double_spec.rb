require File.expand_path('../spec_helper', __FILE__)

module Hessian2
  describe Writer do
    context "when double" do

      it "should write double 0.0 ::= x5b" do
        bin = Hessian2.write(0.0)

        expect(bin.unpack('C').first).to eq(0x5b)
        expect(Hessian2.parse(bin)).to eq(0)
      end


      it "should write double 1.0 ::= x5c" do
        bin = Hessian2.write(1.0)

        expect(bin.unpack('C').first).to eq(0x5c)
        expect(Hessian2.parse(bin)).to eq(1)
      end


      it "should write double represented as byte (-128.0 to 127.0) ::= x5d b0" do
        [ -128.0, 127.0 ].each do |val|
          bin = Hessian2.write(val)

          expect(bin[0].unpack('C').first).to eq(0x5d)
          expect(bin.bytesize).to eq(2)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end


      it "should write double represented as short (-32768.0 to 327676.0) ::= x5e b1 b0" do
        [ -32768.0, 32767.0, -129.0, 128.0 ].each do |val|
          bin = Hessian2.write(val)

          expect(bin[0].unpack('C').first).to eq(0x5e)
          expect(bin.bytesize).to eq(3)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end


      it "should write double represented as float ::= x5f b3 b2 b1 b0" do
        [ -123.456, 123.456 ].each do |val|
          bin = Hessian2.write(val)

          expect(bin[0].unpack('C').first).to eq(0x5f)
          expect(bin.bytesize).to eq(5)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end


      it "should write 64-bit IEEE encoded double ('D') ::= 'D' b7 b6 b5 b4 b3 b2 b1 b0" do
        [ 4.9E-324, 1.7976931348623157E308, Float::INFINITY, -Float::INFINITY ].each do |val|
          bin = Hessian2.write(val)
          
          expect(bin[0]).to eq('D')
          expect(bin.bytesize).to eq(9)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end


      it "should write NAN" do
        val = Float::NAN
        bin = Hessian2.write(val)
          
        expect(bin[0]).to eq('D')
        expect(bin.bytesize).to eq(9)
        expect(Hessian2.parse(bin).nan?).to eq(true)
      end

    end
  end
end

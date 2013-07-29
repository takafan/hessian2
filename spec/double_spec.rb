require 'spec_helper'

module Hessian2
  describe Writer do
    context "when double" do
      it "should write infinite" do
        val = Float::INFINITY
        bin = Hessian2.write(val)

        expect(bin.bytesize).to eq(9)
        expect(Hessian2.parse(bin)).to eq(val)
      end

      it "should write -infinite" do
        val = -Float::INFINITY
        bin = Hessian2.write(val)
        expect(bin.bytesize).to eq(9)
        expect(Hessian2.parse(bin)).to eq(val)
      end

      it "should write nan" do
        val = Float::NAN
        bin = Hessian2.write(val)

        expect(bin.bytesize).to eq(9)
        expect(Hessian2.parse(bin).nan?).to eq(true)
      end

      it "should write 0.0" do
        bin = Hessian2.write(0.0)

        expect(bin.bytesize).to eq(1)
        expect(Hessian2.parse(bin)).to eq(0)
      end

      it "should write 1.0" do
        bin = Hessian2.write(1.0)

        expect(bin.bytesize).to eq(1)
        expect(Hessian2.parse(bin)).to eq(1)
      end

      it "should write octet" do # ival >= -0x80 && ival <= 0x7f
        [ -128.0, 127.0 ].each do |val|
          bin = Hessian2.write(val)

          expect(bin.bytesize).to eq(2)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end

      it "should write short" do # ival >= -0x8000 && ival <= 0x7fff
        [ -32768.0, 32767.0 ].each do |val|
          bin = Hessian2.write(val)

          expect(bin.bytesize).to eq(3)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end

      it "should write mill" do # mills >= -0x80_000_000 && mills <= 0x7f_fff_fff && 0.001 * mills == val
        [ -123.456, 123.456 ].each do |val|
          bin = Hessian2.write(val)

          expect(bin.bytesize).to eq(5)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end

      it "should write double" do
        [ 4.9E-324, 1.7976931348623157E308 ].each do |val|
          bin = Hessian2.write(val)
          
          expect(bin.bytesize).to eq(9)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end
    end

  end
end

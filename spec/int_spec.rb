require File.expand_path('../spec_helper', __FILE__)

module Hessian2
  describe Writer do
    context "when int" do
      
      it "should write one-octet compact int (-x10 to x2f, x90 is 0)" do
        [ -0x10, 0x2f ].each do |val|
          bin = Hessian2.write(val)

          expect(bin.unpack('C').first - 0x90).to eq(val)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end

      it "should write two-octet compact int (-x800 to x7ff)" do
        [ -0x800, 0x7ff, -0x11, 0x30 ].each do |val|
          bin = Hessian2.write(val)

          b1, b0 = bin[0, 2].unpack('CC')
          expect(((b1 - 0xc8) << 8) + b0).to eq(val)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end

      it "should write  three-octet compact int (-x40000 to x3ffff)" do
        [ -0x40000, 0x3ffff, -0x801, 0x800 ].each do |val|
          bin = Hessian2.write(val)

          b2, b1, b0 = bin[0, 3].unpack('CCC')
          expect(((b2 - 0xd4) << 16) + (b1 << 8) + b0).to eq(val)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end

      it "should write 32-bit signed integer ('I')" do
        fixnum_max = 2 ** (0.size * 8 - 2) - 1
        fixnum_min = -(2 ** (0.size * 8 - 2))

        [ fixnum_min > -0x80_000_000 ? fixnum_min : -0x80_000_000, fixnum_max < 0x7f_fff_fff ? fixnum_max : 0x7f_fff_fff, -0x40001, 0x40000 ].each do |val|
          bin = Hessian2.write(val)

          expect(bin[0]).to eq('I')
          expect(bin[1, 4].unpack('l>').first).to eq(val)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end

    end
  end
end

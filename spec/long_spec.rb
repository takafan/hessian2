require File.expand_path('../spec_helper', __FILE__)

module Hessian2
  describe Writer do
    context "when long" do
      
      it "should write one-octet compact long (-x8 to xf, xe0 is 0) ::= [xd8-xef]" do
        (-0x08..0x0f).each do |val|
          bin = Hessian2.write(Hessian2::TypeWrapper.new(:long, val))

          expect(bin.unpack('C').first - 0xe0).to eq(val)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end


      it "should write two-octet compact long (-x800 to x7ff, xf8 is 0) ::= [xf0-xff] b0" do
        -0x800.step(0x7ff, 0x100).select{|x| !(-0x08..0x0f).include?(x)}.each do |val|
          bin = Hessian2.write(Hessian2::TypeWrapper.new(:long, val))

          b1, b0 = bin[0, 2].unpack('CC')
          expect(((b1 - 0xf8) << 8) + b0).to eq(val)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end


      it "should write three-octet compact long (-x40000 to x3ffff) ::= [x38-x3f] b1 b0" do
        -0x40000.step(0x3ffff, 0x10000).select{|x| !(-0x800..0x7ff).include?(x)}.each do |val|
          bin = Hessian2.write(Hessian2::TypeWrapper.new(:long, val))

          b2, b1, b0 = bin[0, 3].unpack('CCC')
          expect(((b2 - 0x3c) << 16) + (b1 << 8) + b0).to eq(val)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end


      it "should write long encoded as 32-bit int ('Y') ::= x59 b3 b2 b1 b0" do
        fixnum_max = 2 ** (0.size * 8 - 2) - 1
        fixnum_min = -(2 ** (0.size * 8 - 2))

        [ -0x80_000_000, 0x7f_fff_fff, -0x40001, 0x40000 ].each do |val|
          bin = Hessian2.write(val <= fixnum_max && val >= fixnum_min ? Hessian2::TypeWrapper.new(:long, val) : val)

          expect(bin[0]).to eq('Y')
          expect(bin[1, 4].unpack('l>').first).to eq(val)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end


      it "should write 64-bit signed long integer ('L') ::= 'L' b7 b6 b5 b4 b3 b2 b1 b0" do
        fixnum_max = 2 ** (0.size * 8 - 2) - 1
        fixnum_min = -(2 ** (0.size * 8 - 2))

        [ -0x8_000_000_000_000_000, 0x7_fff_fff_fff_fff_fff, -0x80_000_001, 0x80_000_000 ].each do |val|
          bin = Hessian2.write(val <= fixnum_max && val >= fixnum_min ? Hessian2::TypeWrapper.new(:long, val) : val)

          expect(bin[0]).to eq('L')
          expect(bin[1, 8].unpack('q>').first).to eq(val)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end

    end
  end
end

require File.expand_path('../spec_helper', __FILE__)

module Hessian2
  describe Writer do
    context "when list" do

      it "should write variable-length list/vector ('U') ::= x55 type value* 'Z'" do
        # not implemented
      end

      it "should write fixed-length list/vector ('V') ::= 'V' type int value*" do
        type = '[int'
        val = (1..9).to_a
        bin = Hessian2.write(Hessian2::TypeWrapper.new(type, val))

        bytes = bin.each_byte
        expect([ bytes.next ].pack('C')).to eq('V')
        expect(Hessian2.parse_string(bytes)).to eq(type)
        expect(Hessian2.parse_int(bytes)).to eq(val.size)
        expect(Hessian2.parse(bin)).to eq(val)
      end

      it "should write variable-length untyped list/vector ('W') ::= x57 value* 'Z'" do
        # not implemented
      end

      it "should write fixed-length untyped list/vector ('X') ::= x58 int value*" do
        val = [ Time.new(2005, 3, 4), '阿门', 59.59 ] * 3
        bin = Hessian2.write(val)
        
        bytes = bin.each_byte
        expect([ bytes.next ].pack('C')).to eq('X')
        expect(Hessian2.parse_int(bytes)).to eq(val.size)
        expect(Hessian2.parse(bin)).to eq(val)
      end

      it "should write fixed list with direct length ::= [x70-77] type value*" do
        type = '[int'
        8.times do |i|
          val = (0...i).to_a
          bin = Hessian2.write(Hessian2::TypeWrapper.new(type, val))

          bytes = bin.each_byte
          expect(bytes.next - 0x70).to eq(val.size)
          expect(Hessian2.parse_string(bytes)).to eq(type)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end

      it "should write fixed untyped list with direct length ::= [x78-7f] value*" do
        8.times do |i|
          val = (0...i).to_a
          bin = Hessian2.write(val)

          bytes = bin.each_byte
          expect(bytes.next - 0x78).to eq(val.size)
          expect(Hessian2.parse(bin)).to eq(val)
        end
      end

    end
  end
end

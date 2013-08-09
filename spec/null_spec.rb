require File.expand_path('../spec_helper', __FILE__)

module Hessian2
  describe Writer do
    context "when null" do
      
      it "should write null ('N') ::= 'N'" do
        val = nil
        bin = Hessian2.write(val)

        expect(bin).to eq('N')
        expect(Hessian2.parse(bin)).to eq(val)
      end

    end
  end
end

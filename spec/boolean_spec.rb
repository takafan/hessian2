require File.expand_path('../spec_helper', __FILE__)

module Hessian2
  describe Writer do
    context "when boolean" do
      
      it "should write true" do
        val = true
        bin = Hessian2.write(val)

        expect(bin).to eq('T')
        expect(Hessian2.parse(bin)).to eq(val)
      end

      it "should write false" do
        val = false
        bin = Hessian2.write(val)

        expect(bin).to eq('F')
        expect(Hessian2.parse(bin)).to eq(val)
      end

    end
  end
end

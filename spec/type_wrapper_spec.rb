require File.expand_path('../spec_helper', __FILE__)

module Hessian2
  describe TypeWrapper do
  	hash = { id: nil, born_at: Time.new(2009, 5, 8), name: '大鸡', price: 99.99 }

		it "should raise error" do
			expect(lambda{ Hessian2::TypeWrapper.new(:unknown) }).to raise_error
		end


		it "should wrap nil" do
			bin = Hessian2.write(Hessian2::TypeWrapper.new(:unknown, nil))

			expect(bin).to eq('N')
			expect(Hessian2.parse(bin)).to eq(nil)
		end


		it "should wrap long" do
			[ 59, '59' ].each do |val|
				[ 'L', 'l', 'Long', 'long', :long ].each do |type|
					bin = Hessian2.write(Hessian2::TypeWrapper.new(type, val))

					b1, b0 = bin[0, 2].unpack('CC')
		      expect(((b1 - 0xf8) << 8) + b0).to eq(Integer(val))
		      expect(Hessian2.parse(bin)).to eq(Integer(val))
				end
			end
		end


		it "should wrap int" do
			[ 0x7f_fff_fff, '0x7f_fff_fff' ].each do |val|
				[ 'I', 'i', 'Integer', 'int', :int ].each do |type|
					bin = Hessian2.write(Hessian2::TypeWrapper.new(type, val))

					expect(bin[0]).to eq('I')
	        expect(bin[1, 4].unpack('l>').first).to eq(Integer(val))
	        expect(Hessian2.parse(bin)).to eq(Integer(val))
				end
			end
		end


		it "should wrap binary" do
			val = 'b' * 59
			[ 'B', 'b', 'Binary', 'bin', :bin ].each do |type|
				bin = Hessian2.write(Hessian2::TypeWrapper.new(type, val))

				b1, b0 = bin[0, 2].unpack('CC')
        expect(256 * (b1 - 0x34) + b0).to eq(val.size)
        expect(bin.size).to eq(2 + val.size)
        expect(Hessian2.parse(bin)).to eq(val)
			end
		end


		it "should wrap monkey" do
			[ Monkey.new(hash), AnotherMonkey.new(hash) ].each do |val|
				bin = Hessian2.write(Hessian2::TypeWrapper.new('com.sun.java.Monkey', val))

				_hash = Hessian2.parse(bin, nil, symbolize_keys: true)
				expect([ _hash[:born_at], _hash[:name], _hash[:price] ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
			end
		end


		it "should wrap long array" do
			bin = Hessian2.write(Hessian2::TypeWrapper.new('[long', [ 59, 69, 79, 89, 99 ]))

      expect(Hessian2.parse(bin)).to eq([ 59, 69, 79, 89, 99 ])
		end


		it "should wrap int array" do
			bin = Hessian2.write(Hessian2::TypeWrapper.new('[int', [ 0x7f_fff_ffb, 0x7f_fff_ffc, 0x7f_fff_ffd, 0x7f_fff_ffe, 0x7f_fff_fff ]))

      expect(Hessian2.parse(bin)).to eq([ 0x7f_fff_ffb, 0x7f_fff_ffc, 0x7f_fff_ffd, 0x7f_fff_ffe, 0x7f_fff_fff ])
		end


		it "should wrap binary array" do
			bin = Hessian2.write(Hessian2::TypeWrapper.new('[bin', [ 'b' * 59, 'b' * 69, 'b' * 79, 'b' * 89, 'b' * 99 ]))

      expect(Hessian2.parse(bin)).to eq([ 'b' * 59, 'b' * 69, 'b' * 79, 'b' * 89, 'b' * 99 ])
		end


		it "should wrap monkey array" do
			bin = Hessian2.write(Hessian2::TypeWrapper.new('[com.sun.java.Monkey', [ nil, Monkey.new(hash), AnotherMonkey.new(hash) ]))

			_hash1, _hash2, _hash3 = Hessian2.parse(bin, nil, symbolize_keys: true)
			expect(_hash1).to eq(nil)
			[ _hash2, _hash3 ].each do |_hash|
				expect([ _hash[:born_at], _hash[:name], _hash[:price] ]).to eq([ hash[:born_at], hash[:name], hash[:price] ])
			end
		end
		
		
	end
end

require 'spec_helper.rb'

# Define some sample structs for test purposes
class Inner < NiceFFI::Struct
    layout  :one, :uint8,
            :two, :uint32,
            :three, :uint16
end
class Outer < NiceFFI::Struct
    layout  :header, :uint8,
            :nested, Inner,
            :footer, :uint16
end

describe NiceFFI::Struct do

  it "generates accessors for nested structures" do
    x = Outer.new ""
    expect( x ).to respond_to :nested
    expect( x.nested ).to be_a( Inner )
    expect( x.nested ).to respond_to :one
  end

  describe "to_hash" do
    before :all do
      @x = Inner.new [ 3, 2, 1 ]
      @h = @x.to_hash
    end

    it "generates the correct number of elements" do
      expect( @h.length ).to eql @x.members.length
    end

    it "generates the correct sequence of keys" do
      expect( @h.keys ).to match_array @x.members
    end

    it "generates the correct values" do
      @h.each {|k,v|
          expect( v ).to eql @x[k]
      }
    end

    it "recursively encodes nested structures" do
      o = Outer.new ""
      h = o.to_hash
      expect( h[:nested] ).to be_a( Hash )
    end
  end

  describe "#init_from_hash" do
    before :all do
      @hash = { :one => 1, :two => 2, :three => 3 }
    end
    
    it "loads the correct values" do
      x = Inner.new @hash

      expect( x[:one] ).to eql 1
      expect( x[:two] ).to eql 2
      expect( x[:three] ).to eql 3
    end

    it "only alters the specified fields" do
      x = Inner.new @hash.reject{|x| x == :two}
      
      expect( x[:one] ).to eql 1
      expect( x[:two] ).to eql 0
      expect( x[:three] ).to eql 3
    end

    it "rejects unknown fields" do
      expect {
        h = @hash.merge( { :dummy => 0 } )
        x = Inner.new h
      }.to raise_error( NoMethodError )
    end

    it "can be used to re-constitute a nested structure" do
      x = Outer.new [rand(250), [rand(250), rand(250), rand(250)], rand(250)]

      y = Outer.new x.to_hash

      expect( y[:header] ).to eql x[:header]
      expect( y[:footer] ).to eql x[:footer]
      expect( y[:nested][:one] ).to eql x[:nested][:one]
      expect( y[:nested][:two] ).to eql x[:nested][:two]
      expect( y[:nested][:three] ).to eql x[:nested][:three]
    end
  end

  describe "to_ary" do
    before :all do
      @init_data = [ 1, 2, 3 ]
      @x = Inner.new @init_data
      @a = @x.to_ary
    end

    it "generates the correct number of elements" do
      expect( @a.length ).to eql @x.members.length
    end

    it "generates the correct sequence of values" do
      expect( @a ).to match_array @init_data
    end

    it "recursively encodes nested structures" do
      o = Outer.new ""
      a = o.to_ary
      expect( a[1] ).to be_a( ::Array )
    end
  end

  describe "#init_from_ary" do
    before :all do
      @init_data = [ 1, 2, 3 ]
    end
    
    it "loads the correct values" do
      x = Inner.new @init_data

      expect( x[:one] ).to eql 1
      expect( x[:two] ).to eql 2
      expect( x[:three] ).to eql 3
    end

    it "errors if array is too small" do
      expect {
        x = Inner.new @init_data[0...-1]
      }.to raise_error( IndexError )
    end

    it "errors if array is too large" do
      expect {
        x = Inner.new @init_data + [5]
      }.to raise_error( IndexError )
    end

    it "can be used to re-constitute a nested structure" do
      x = Outer.new [rand(250), [rand(250), rand(250), rand(250)], rand(250)]

      y = Outer.new x.to_ary

      expect( y[:header] ).to eql x[:header]
      expect( y[:footer] ).to eql x[:footer]
      expect( y[:nested][:one] ).to eql x[:nested][:one]
      expect( y[:nested][:two] ).to eql x[:nested][:two]
      expect( y[:nested][:three] ).to eql x[:nested][:three]
    end
  end

end

require 'test/unit'

require './lib/structure.rb'

class TestStructure < Test::Unit::TestCase

    def setup
        @customer = Structure.new(:name, :address, :zip)
        @joe = @customer.new('Joe Smith', '123 Maple, Anytown NC', 12345)
    end

    def test_create_named_structure
        Structure.new('Named')
        assert_true(Structure.const_defined?('Named'))
        assert_equal(Structure::Structure, Structure::Named.superclass)
    end

    def test_create_anonymous_structure
        anonym = Structure.new(:one, :two)
        assert_equal(Class, anonym.class)
        assert_equal(Structure::Structure, anonym.superclass)
    end

    def test_creation_block_passing
        Structure.new('Struct') do
            def ping
                'pong'
            end
        end

        assert_equal('pong', Structure::Struct.new.ping)
    end

    def test_instantiation_with_more_arguments_throws_error
        assert_raise ArgumentError do
            @customer.new('Joe Smith', '123 Maple, Anytown NC', 12345, 'extra param')
        end
    end

    def test_array_access_instantiation_structure_class
        Structure.new('Customer', :name, :address)
        dave = Structure::Customer['Dave']
        assert_equal('#<struct Customer name="Dave", address=nil>', dave.inspect)
    end

    def test_equality
        joejr = @customer.new('Joe Smith', '123 Maple, Anytown NC', 12345)
        jane = @customer.new('Jane Doe', '456 Elm, Anytown NC', 12345)
        
        assert_true(@joe == joejr)
        assert_false(@joe == jane)
    end

    def test_attributes_accessing
        assert_equal('Joe Smith', @joe.name)
        assert_equal('Joe Smith', @joe['name'])
        assert_equal('Joe Smith', @joe[:name])
        assert_equal('Joe Smith', @joe[0])
    end
    
    def test_attributes_setting
        @joe['name'] = 'Luke'
        @joe[:zip]   = '90210'
        
        assert_equal('Luke', @joe.name)
        assert_equal('90210', @joe.zip)
    end

    def test_dig
        foo = Structure.new(:a)
        f = foo.new(foo.new({b: [1, 2, 3]}))
        
        assert_equal(1, f.dig(:a, :a, :b, 0))
        assert_equal(nil, f.dig(:b, 0))
        assert_raise TypeError do # TypeError: no implicit conversion of Symbol into Integer
            f.dig(:a, :a, :b, :c)
        end
    end

    def test_each
        assert_instance_of(Array, @joe.each) 
    end

    def test_each_pair
        pairs = @joe.each_pair

        assert_instance_of(Array, pairs) 
        assert_equal([:name, 'Joe Smith'], pairs[0]) 
    end

    def test_eql?
        joejr = @customer.new('Joe Smith', '123 Maple, Anytown NC', 12345)
        jane = @customer.new('Jane Doe', '456 Elm, Anytown NC', 12345)
        
        assert_true(@joe.eql?(joejr))
        assert_false(@joe.eql?(jane))
    end

    def test_inspect
        assert_equal(
            '#<struct name="Joe Smith", address="123 Maple, Anytown NC", zip=12345>',
            @joe.inspect
        )

        Structure.new('Customer', :name, :address, :zip)
        joe = Structure::Customer.new('Joe Smith', '123 Maple, Anytown NC', 12345)
        
        assert_equal(
            '#<struct Customer name="Joe Smith", address="123 Maple, Anytown NC", zip=12345>',
            joe.inspect
        )
    end
    
    def test_to_s
        assert_equal(
            '#<struct name="Joe Smith", address="123 Maple, Anytown NC", zip=12345>',
            @joe.to_s
        )
    end

    def test_length
        assert_equal(3, @joe.length)
    end

    def test_members
        assert_equal([:name, :address, :zip], @joe.members)
    end

    def test_select
        lots = Structure.new(:a, :b, :c, :d, :e, :f)
        l = lots.new(11, 22, 33, 44, 55, 66)
        
        assert_equal([22, 44, 66], l.select { |v| v.even? })
    end

    def test_size
        assert_equal(3, @joe.size)
    end

    def test_to_a
        assert_equal('123 Maple, Anytown NC', @joe.to_a[1])
    end

    def test_to_h
        assert_equal('123 Maple, Anytown NC', @joe.to_h[:address])
    end

    def test_values
        assert_equal('123 Maple, Anytown NC', @joe.values[1])
    end

    def test_values_at
        assert_equal(['Joe Smith', 12345], @joe.values_at(0, 2))
    end

end

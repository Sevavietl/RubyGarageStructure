require 'json'
require 'digest'

module Structure
    class Structure
        class << self
            attr_accessor :attrs, :structs

            def [](*keys)
                new(*keys)
            end
        end
        
        def initialize(*args)
            raise ArgumentError if args.length > length
            
            members.zip(args) { |attr, value| self[attr] = value }
        end

        def ==(other)
            hash == other.hash
        end

        def [](key)
            key.is_a?(Integer) ? to_a[key] : send(key.to_sym)
        end
        
        def []=(key, value)
            send("#{key.to_sym}=", value)
        end

        def dig(*keys)
            keys.inject(self) do |carr, key|
                begin 
                    carr[key]
                rescue NoMethodError
                    nil
                end
            end
        end

        def each(&block)
            block_or_enum(to_a, &block)
        end

        def each_pair(&block)
            block_or_enum(members.zip(to_a), &block)
        end

        def eql?(other)
            self == other
        end

        def hash
            Digest::MD5.hexdigest(JSON.generate(to_h.merge({
                :class_hash_with_some_long_key_so_its_improbable_to_match_any_member => self.class
            })))
        end

        def inspect
            string = super.gsub(/( \@)(?=\w)+/, ' ')

            if /#<Class:/.match(self.class.to_s)
                string.gsub!(/(#<Class:[\dxa-f>:]+)(?= )/, 'struct')
            elsif /Structure::/.match(self.class.to_s)
                string.gsub!(/(Structure::)(\w+)(:[\dxa-f]+)/, 'struct \2')
            end

            string
        end

        def to_s
            inspect
        end

        def length
            members.length
        end

        def members
            self.class.attrs
        end

        def select(&block)
            block_or_enum(to_a, :select, &block)
        end

        def size
            length
        end

        def to_a
            members.inject([]) { |acc, attr| acc.push(self[attr]) }
        end

        def to_h
            Hash[each_pair]
        end

        def values
            to_a
        end

        def values_at(*positions)
            to_a.values_at(*positions)
        end

        private

        def block_or_enum(enum, func = :each, &block)
            if block_given?
                enum.send(func, &block)
            else
                enum
            end
        end
    end
end

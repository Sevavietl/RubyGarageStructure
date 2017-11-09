require_relative './structure/structure.rb'

module Structure
    class << self
        def new(*attrs, &block)
            name = attrs.shift
    
            if valid_name(name)
                self.const_set(name, create_struct(*attrs.map(&:to_sym), &block))
            else 
                create_struct(*attrs.unshift(name).map(&:to_sym), &block)
            end
        end
    
        private

        def valid_name(name)
            name.is_a?(String) && /^[A-Z]/.match(name)
        end

        def create_struct(*attrs, &block)
            klass = Class.new(Structure, &block)
            klass.send(:attr_accessor, *attrs)
            klass.send('attrs=', attrs)
            klass
        end
    end    
end

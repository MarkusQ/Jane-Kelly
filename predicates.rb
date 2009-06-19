class Predicate < Proc
    def ===(x)
        call x
        end
    end

Even = Predicate.new { |x| x % 2 == 0}

def Divisible_by n
    Predicate.new { |x| x % n == 0}
    end 

A_prime = Predicate.new { |x| (2..Math::sqrt(x)).all? {|i| x % i != 0 }}

def Modulo n
    result = Object.new
    class << result
        attr_accessor :modulo_base
        def == r
            Predicate.new { |x| x % modulo_base == r }
            end
        end
    result.modulo_base = n
    result
    end

class Fixnum
    original_index = instance_method(:[])
    define_method(:[]){|*args|
        if args.length == 1 and args[0].respond_to? :modulo_base
            args[0] == self
          else
            original_index.bind(self).call(*args)
          end
        }
    end

(1..20).each { |i| 
    case i
      when 7 [(Modulo 8)]   : print "#{i} == 7 (mod 8)\n"
      when (Modulo 6) == 3  : print "#{i} == 3 (mod 6)\n"
      when Even             : print "#{i} is even\n"
      when Divisible_by(5)  : print "#{i} is divisible by 5\n"
      end 
    }

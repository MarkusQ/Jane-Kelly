

$mm_limit = 0
def mm_limit
    $mm_limit += 1
    fail if $mm_limit == 5
    result = yield
    $mm_limit -= 1
    result
    end


$values = {}
class Object
    def is?(cls)
        is_a? cls
        end
    def value
        self
        end
    def as_value
        A_value.equ_to(self)
        end
    def unify(other)
        self == other or other.is? A_value and other.unify(self)
        end
    end

class Numeric
    def ^(other)
        self**other
        end
    end

class Fixnum
    def ^(other)
        self**other
        end
    end

Scope = []
class << Scope
    def enclose(b = {})
        push(b)
        result = yield
        pop
        result
        end
    def current
        last || {}
        end
    end

class Symbol
    def method_missing(*args)
        mm_limit { (@variable ||= ((self.to_s =~ /^_/) ? A_gobbler : A_variable).new(self)).send(*args) }
        end
    def unify(other)
        method_missing(:unify,other)
        end
    end

class Hash
    def unify(other)
        print "  #{inspect}.unify #{other.class}:#{other.inspect}\n"
        all? { |k,t| print "    #{k.class}:#{k}.unify #{other.inspect} --> #{k.unify(other)}\n"; other.is_a? t and k.unify(other) }
        end
    end

class A_value
    attr :forms
    def self.equ_to(x)
        $values[x] || new(x)
        end
    def initialize(*forms)
        @forms = [forms].flatten
        raise "What, _no_ forms from the start?!?" unless @forms
        end
    def +(other)
        A_value.new A_sum.new(self,other)
        end
    def *(other)
        A_value.new A_product.new(self,other)
        end
    def -(other)
        self + -1*other
        end
    def ^(other)
        self
        end
    def coerce(other)
        [other.as_value,self]
        end
    def as_value
        self
        end
    def inspect
        if @forms.length == 1
            @forms.first.inspect
          else
            "{\n#{@forms.collect {|r| r.inspect }.join(",\n")}\n}"
          end
        end
    def pairings(patterns,reps = @forms,&block)
        if patterns.empty?
            yield
          else
            reps.each { |v|
                print "Pairing #{v.inspect} with #{patterns.first.inspect}\n"
                Scope.enclose(Scope.current.dup) {
                    pairings(patterns[1..-1],reps-[v],&block) if patterns.first.unify(v)
                    }
                }
          end
        end
    def apply_rules
        $rules.each { |rule|
            pairings(rule.preconditions) { @forms |= [rule.action.call].compact }
            }
        self
        end
    def method_missing(*args)
        raise "What, _no_ forms?!?" unless @forms
        if @forms.length == 1 
            print "#{@forms.inspect} sending #{args.inspect} to #{@forms.first}\n"
            @forms.first.send(*args)
          else
            print "#{@forms.inspect} sending #{args.inspect} to ...and that's the problem.\n"
            super
          end
        end
    def unify(other)
        true #self == other or @forms.include? other #false #@forms.find { |r| r.unify other }
        end
    end

class An_expression < Numeric
    attr_reader :name,:parameters,:value
    def initialize(name,*args,&block)
        @name = name
        @value = block
        @parameters = args
        end
    def unify(other)
        (@name == other.name) and @parameters.zip(other.parameters).all? { |p,ap| result = p.unify(ap); print "    #{p.class}:#{p.inspect}.unify(#{ap.class}:#{ap.inspect}) = #{result}\n"; result }
        end
    def eval(actual)
        Scope.enclose { (p ['unified',Scope]; @value.call) if unify(actual) }
        end
    def inspect
        if parameters.empty?
            name
          elsif [:+,:*,:/,:-].include? name
            "(#{parameters.collect { |t| t.inspect}.join(" #{name} ")})"
          else
            "#{name}(#{parameters.collect { |p| p.inspect }.join(",")})"
          end
        end
    def coerce(other)
        [other.as_value,self.as_value]
        end
    def method_missing(meth,*args)
        p [self,meth,args]
        mm_limit { as_value.send(meth,*args) }
        end
    end

class A_variable < A_value
    def initialize(name)
        @name = name
        end
    def as_value
        Scope.current[self] || self
        end
    def value
        as_value
        end
    def unify(other)
        (Scope.current[self] ||= other).unify(other)
        end
    def inspect
        @name
        end
    end

class Gobbler < A_variable
    def unify(other)
        true
        end
    end

class A_sum < An_expression
    def initialize(*terms)
        super(:+,*terms)
        end
    end

class A_product < An_expression
    def initialize(*factors)
        super(:*,*factors)
        end
    end

class A_method < An_expression
    def as_value
        mm_limit { A_value.new self.class.new(name,*@parameters.collect { |a| a.as_value }) }
        end
    end


_ = __ = ___ = ____ = :_ #.as_value
Infinity = 1.0/0.0

def partial_function(sym)
    eval %Q{
        def #{sym}(*args,&block)
            A_method.new(#{sym.inspect},*args,&block)
            end
         }
    end

$templates = Hash.new { |h,k| h[k] = [] }
def def_partial(template)
    $templates[template.name] << template
    end

partial_function :F

def_partial F(1) do 
    1
    end
def_partial F(:n) do
    :n * (:n - 1)
    end

p F(7).value

%q{
#---------------------------------------------------------------------------------------------------

def apply(template)
    $templates[template.name].collect { |t| t.eval(template) }.compact
    end

class A_rule
    attr_reader :preconditions,:action
    def initialize(*args,&block)
        @preconditions = args
        @action = block
        end
    def applies_to(v)
        @test.call(v) && (nv = @apply.call(v)) && nv.not_equivalent_to(v) && v.join(nv)
        end
    end

$rules = []
def define_rule(*args,&block)
    $rules << A_rule.new(*args,&block)
    end

define_rule( {:a=>A_method}       ) { 
    p ['called with ',:a,:a.name,:a.as_value,Scope]
    $templates[:a.name].find { |t| 
        print "Trying #{t.inspect}\n"
        result = t.eval(:a.as_value) 
        result
        } 
    }

define_rule( :a + (:b + :c)       ) { (:a + :b) + :c }
define_rule( :a + :b              ) { :b + :a }
define_rule( :a * (:b * :c)       ) { (:a * :b) * :c }
define_rule( :a * :b              ) { :b * :a }
define_rule( :a * (:b + :c)       ) { :a*:b + :a*:c }
define_rule( :a,:v1 + :v2*:a      ) { :v1/(1-:v2) }

def saturate(tree)
    changed = true
    while changed
        changed = false
        rules.each { |r|
            nodes.each { |n|
                changed ||= r.applies_at n
                }
            }
        end
    print tree.simpilest_representation
    end
#---------------------------------------------------------------------------------------------------

def Best_T(*args,&block)
    A_method.new(:Best_T,*args,&block)
    end

def Odds(*args,&block)
    A_method.new(:Odds,*args,&block)
    end

#---------------------------------------------------------------------------------------------------
#
# Odds(X,N,T,P1,P2) -- Odds of X winning in N turns when it's T's turn and the score is P1,P2
#
def_partial Odds( 1,__,__,100,___) {1.0} # Player 1 wins if he get 100
def_partial Odds( _,__,__,100,___) {0.0}
def_partial Odds( 2,__,__,___,100) {1.0} # Player 2 wins if she gets 100
def_partial Odds( _,__,__,___,100) {0.0}
def_partial Odds( 0, 0,__,___,___) {1.0} # There's no other way to win immediately
def_partial Odds( _, 0,__,___,___) {0.0}
def_partial Odds( 1,__, 2,___,___) {0.0} # Player 1 can't win on 2's turn 
def_partial Odds( 2,__, 1,___,___) {0.0} # Player 2 can't win on 1's turn 

def_partial Odds( 1, 1, 1, 99,___) {0.5} # If player 1 has 99 and it's his turn, he has a 50% chance 
def_partial Odds( 0, 1, 1, 99,___) {0.5} #     to win in one turn, or it could be left undecided.

def_partial Odds( 2, 1, 2,___, 99) {0.5} # Ditto player 2 for player 2 (Best_T(___, 99) --> 1)
def_partial Odds( 0, 1, 2,___, 99) {0.5} # 
def_partial Odds( 2, 1, 2,:p1,:p2) {}
def_partial Odds( 0, 1, 2,:p1,:p2) {}

def_partial Odds( 1,:n, 1,:p1,:p2) {
    Odds( 1, 1, 1, :p1, :p2) + 
    Odds( 0, 1, 1, :p1, :p2) * (
        0.5*Odds( 1, :n-1, 2, :p1+1,:p2) +
        0.5*Odds( 1, :n-1, 2, :p1,  :p2)
        )
    }
def_partial Odds( 2,:n, 2,:p1,:p2) {
    Odds( 2, 1, 2, :p1, :p2) + 
    Odds( 0, 1, 2, :p1, :p2) * (
        (    0.5^Best_T(:p1,:p2))*Odds( 1, :n-1, 2, :p1,:p2+2^Best_T(:p1,:p2)) +
        (1.0-0.5^Best_T(:p1,:p2))*Odds( 1, :n-1, 2, :p1,:p2                  )
        )
    }




def index_for_maximum(range)
    range.collect { |i| yield i }
    end
#
# 
#
def_partial Best_T(___, 99) {1}
def_partial Best_T(:p1,:p2) {
    # i which maximizes 
    #     (    0.5^i)*Odds( 1,Infinity, 2, :p1,:p2+2^i) +
    #     (1.0-0.5^i)*Odds( 1,Infinity, 2, :p1,:p2    )
    #   for all i from 1 to ln2(100-:p2)
    }

# if_then_else(c,t,e)
}
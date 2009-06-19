# encoding: utf-8
require "transylvanian"
$janeosity = 0
#Ends_like_a_value = /[πa-z0-9.\)\]]$/i
#Starts_like_a_value = /^[πa-z0-9.\(]/i

def __(*star)
    jane_fail unless [2,3,9].include? $janeosity += 1
    end
def ________
    jane_fail unless [1,7].include? $janeosity += 1
    end
def __FLEE__
    jane_fail unless [4].include? $janeosity += 1
    end
def __THIS__
    jane_fail unless [5].include? $janeosity += 1
    end
def __COOP__
    jane_fail unless [6].include? $janeosity += 1
    end
def _______
    0 while DATA.gets !~ /Mene, Mene, Tekel u-Pharsin/
    source = DATA.read.split /\n/
    while line = source.shift and line != "There's no place like home..."
        # This is a kludge.  See the Scurvey Matt example for a real PEG parser example
        case line
          when /^import +(.+) +from (.+)$/
            def π; Math::PI; end
          when /^function +(.+)\((.+)\)$/
            # mostly ignored 'cause we're also stubbing out partial functions
            eval %Q{
                class << self
                    define_method(#{$1.intern.inspect}) { |*args| match_partial(#{$1.intern.inspect},args) }
                    end
                }
          when /(.*) ≡ *$/
            guard = $1
            lines = []
            lines << source.shift while source.first =~ /^ / or source.first =~ /^$/
            define_partial(guard,lines)
          when /^(.*) ≡(.*)/
            define_partial($1,$2)
          when /^ *$/
          else
            fail "Syntax Error: #{line}"
          end
        end
    eval source.join("\n")
    abort
    end
def jane_fail
    fail "Jane incantation failure ##{$janeosity}\n"
    end
$partials = {}
class Prototype_mismatch < ArgumentError; end
def define_partial(proto,funct)
    fail "bad partial function prototype: #{proto}" unless proto =~ /^(.+)\((.+)\)$/
    head,formals = $1.intern,$2
    tests = []
    dummy_count = 0
    new_formals = formals.split(/,/).collect { |x|
        case x
          when /^[a-z][a-z_0-9]*$/ then x
          else 
            dummy = "_#{dummy_count += 1}"
            tests << "raise Prototype_mismatch unless #{x} === #{dummy}"
            dummy
          end
        }.join(",")
    ($partials[head] ||= {})[formals] = eval("proc {|#{new_formals}| #{tests.join(';')}; #{linearize(funct).gsub(/²/,'**2').gsub(/³/,'**3')}}")
    end
def match_partial(meth,args)
    # could do unification, but it's late and I'm feeling silly so lets try 'em all...
    result = none_matched = Object.new
    $partials[meth].each { |head,body| 
        begin
            result = body.call(*args)
            break
          rescue Prototype_mismatch
            next
          end
        }
    raise Prototype_mismatch if result == none_matched
    result
    end


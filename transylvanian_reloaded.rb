#
# Add some extensions to make talking about rectangular areas or text a little nicer
#
class String
    def blank?
        self =~ /^\s*$/
        end
    end

class Array
    def index_range
        0...length
        end
    def columns(range)
        collect { |x| x[range] || '' }
        end
    def rows(range)
        self[range]
        end
    def method_missing(meth,*args)
        if meth.to_s =~ /\?$/
            all?    { |el| el.send(meth,*args) }
          else
            collect { |el| el.send(meth,*args) }
          end
        end
    end
#
# Parse formulas 
#
# Break a line into segments of whitespace or dashed lines or numbers or other such...
#
def terms(line)
    col = 0
    line.scan(/(\s+|[-+]?\d+\.?\d*|-+|\w+|.)/).flatten.collect { |s| [s,col...(col+=s.length)] }
    end
#
# The "main line" of a formula will have either:
#
#    * Some value/expression, with nothing above or below it
#    * Blanks above/below sub/superscripts
#    * A line of three or more dashes with stuff above and below
#
def good_divider(lines,i)
  return true
#    above_and_below = lines.rows(0...i)+lines.rows((i+1)..-1)
#    p "Never getting called?"
#    segments(lines[i]).all? { |text,range|
#        text =~ /^( +|---+)$/ or above_and_below.columns(range).blank?
#        }
    end
#
# Recursively linearize a formula.  
#     * Start off dealing with some edge cases 
#       - multi-line string instead of array of strings
#       - blank lines above / below
#       - empty region
#     * Find the main line of the formula by looking for the 
#       line with the leftmost non-blank and breaking ties based
#       on various heuristics
#     * Run through the segments on the main line, buiding up the 
#       linearized formula by recursively liniarizing the stuff
#       above and below
#
def linearize(expression)
    return '' if cleaned(expression).empty?
    expression = cleaned(expression)
    previous_significant_term = nil
    terms( dividing_line_text(expression) ).collect { |term, term_position| 
        multiplier = term_multiplier(term, previous_significant_term) 
        dividing_line = /^---+$/
        blank_term = /^ *$/
        subexpression = expression.columns(term_position)
        expanded_term = case term
          when blank_term:   expand_divisor( lower_term(subexpression) ) + expand_exponent( upper_term(expression, term_position) )
          when dividing_line: expand_quotient( upper_term(expression, term_position), lower_term(subexpression) )
          else           term.strip
        end
        previous_significant_term = expanded_term if not term =~ blank_term
        multiplier + expanded_term
      }.join
end


def dividing_line_text(expression)
  
  cleaned(expression)[dividing_line( cleaned(expression) )]
  
end

def expand_divisor(term)

  term.blank? ? '' : "[" + linearize(term) + "]"

end    

def expand_exponent(term)

  term.blank? ? '' : "**(" + linearize(term) + ")"

end    

def expand_quotient(numerator, denominator)

  "((" + linearize(numerator) + ")/(" + linearize(denominator) + "))"

end
    
def upper_term(quotient, range)

  cleaned(quotient).rows(0...dividing_line( cleaned(quotient) )).columns(range)

end

def lower_term(expression)

  expression.rows( (dividing_line( expression ) + 1) .. -1 )

end

def cleaned(lines)

  lines = lines.split(/\n/) if lines.is_a? String
  return lines.select { |l| not l.blank? }

end

# This is a crap name, but a start. - Matt
def dividing_line(lines)

  lines.
    index_range.
    sort_by { |i| lines[i] =~ /^( *)(-*)/; [$1.length,-$2.length,i] }[0] # first was never being called?  
end  

# Emits a * if terms are adjacent.  
def term_multiplier(text, last_text)

  (last_text =~ /[a-z0-9.\)\]]$/i and text =~ /^[a-z0-9.\(]/i) ? '*' : ''

end

#
# Mathematica has functions that use square brackets and start with a capital letter,
#    so we add some to ruby. 
#
class A_mathematica_function
    def initialize(f)
        @f = f
        end 
    def [](*args)
        Math.send(@f,*args)
        end
    end
(Math.methods-Object.methods).each { |f|
    Kernel.const_set(f.capitalize,A_mathematica_function.new(f))
    }
#
# Test cases
#
print linearize(%q{
     a b
}),"\n"

print linearize(%q{
     3+i
    2
}),"\n"

print linearize(%q{
   3       3+i
  ---  +  2
   4
}),"\n"


print linearize(%q{
   3       3+i
  ---  +  2             2*i+1    i
   4                   2     *  3
------------------  + ---------------
         1                   7
  sqrt( ---- )            -1
         2
}),"\n"


print linearize(%q{

            2    2     2              x
    x Sqrt[r  - x ] + r  ArcTan[-------------]
                                      2    2
                                Sqrt[r  - x ]
    ------------------------------------------
                        2
    
}),"\n"

class << self;
   define_method(:f,&eval("proc {|a,b,c| #{linearize(%q{
                     2
         -b + Sqrt[ b  - 4 a c ]
         -----------------------
                 2 a
       })}}"))
   end

p f(6,7,1)

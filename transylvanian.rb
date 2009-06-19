#
# Add some extensions to make talking about rectangular areas or text a little nicer
#
class String
    def blank?
        self =~ /^\s*$/
        end
    def if(cond)
        cond ? self : ''
        end
    def unless(cond)
        cond ? '' : self
        end
    end

module Enumerable
    def method_missing(meth,*args)
        if meth.to_s =~ /^all_(.*\?)$/
            instance_eval(%Q{
                def #{meth}(*args)
                    all?    { |el| el.send(#{$1.inspect},*args) }
                    end
                })
            send(meth,*args)
          elsif meth.to_s =~ /^collect_(.*)$/
            instance_eval(%Q{
                def #{meth}(*args)
                    collect    { |el| el.send(#{$1.inspect},*args) }
                    end
                })
            send(meth,*args)
          else
            super(meth,*args)
          end
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
    def max
        inject {|a,b| (a > b) ? a : b }
        end
    def pad_to_match_longest
        collect_ljust collect { |x| x.length }.max
        end
    end
#
# Parse formulas 
#
# Break a line into segments of whitespace or dashed lines or numbers or other such...
#
def segments(line)
    #return [] if line.nil? or line.blank?
    col = 0
    (line+' '*99).scan(/(\s+|[-+]?\d+\.?\d*|-+|\w+|.)/).flatten.collect { |s| [s,col...(col+=s.length)] }
    end
#
# The "main line" of a formula will have either:
#
#    * Some value/expression, with nothing above or below it
#    * Blanks above/below sub/superscripts
#    * A line of three or more dashes with stuff above and below
#
def good_divider(lines,i)
    above_and_below = lines.rows(0...i)+lines.rows((i+1)..-1)
    segments(lines[i]).all? { |text,range|
        text =~ /^( +|---+)$/ or above_and_below.columns(range).blank?
        }
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
def linearize(lines)
    lines = lines.split(/\n/) if lines.is_a? String
    lines = lines.select { |l| not l.blank? }
    return '' if lines.empty?
    i = lines.
      index_range.
      sort_by { |i| lines[i] =~ /^( *)(-*)/; [$1.length,-$2.length,i] }.
      first { |i| good_divider(lines,i) }
    above,below = lines.rows(0...i),lines.rows((i+1)..-1)
    last_text = nil
    segments(lines[i]).collect { |text,range|
        implicit_mult = ((last_text =~ /[a-z0-9.\)\]]$/i and text =~ /^[a-z0-9.\(]/i))? '*' : ''
        #p [implicit_mult,last_text,text,last_text =~ /[a-z0-9.\)\]]$/i,text =~ /^[a-z0-9.\(]/i]
        a = above.columns(range)
        b = below.columns(range)
        implicit_mult + case text
          when /^ *$/   then (b.all_blank? ? '' : "[#{  linearize(b)}]") + (a.all_blank? ? '' : "**(#{linearize(a)})")
          when /^---+$/ then last_text = "((#{linearize(a)})/(#{linearize(b)}))"
          else               last_text = text.strip
          end
      }.join
    end
#
#
#
def lines_from(src)
    src = src.split(/\n/).pad_to_match_longest if src.is_a? String
    src = src.select { |l| not l.blank? }
    def src.split_vertically
        i = index_range.
            sort_by { |i| self[i] =~ /^( *)(-*)/; [$1.length,-$2.length,i] }.
            first { |i| good_divider(self,i) } || 0
        def (self[i]).split_horizontally 
            return [] if nil? or blank?
            col = 0
            scan(/(\s+|[-+]?\d+\.?\d*|-+|\w+|.)/).flatten.collect { |s| [s,col...(col+=s.length)] }
            end
        [rows(0...i),self[i],rows((i+1)..-1)]
        end
    src
    end

Ends_like_a_value = /[\w0-9.\)\]]$/i
Starts_like_a_value = /^[\w0-9.\(]/i
def adjacent_values(a,b)
    a =~ Ends_like_a_value and b =~ Starts_like_a_value
    end
#
#
#
Whitespace = /^ *$/
Dashes = /^---+$/
#
#
#
def linearize(s)
    lines_above,pivot_line,lines_below = lines_from(s).split_vertically
    last_text = nil
    pivot_line.split_horizontally.collect { |text,range|
        a = linearize lines_above.columns(range)
        b = linearize lines_below.columns(range)
        '*'.if(adjacent_values(last_text,text)) + case text
          when Whitespace then "[#{b}]".unless(b.blank?) + 
                             "**(#{a})".unless(a.blank?)
          when Dashes     then last_text = "((#{a})/(#{b}))"
          else                 last_text = text.strip
          end
      }.join
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
if __FILE__ == $0
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
    
    print linearize(%q{
    
            2    2     2              x
    x Sqrt[r  - x ] + r  ArcTan[-------------]
                                      2    2
                                Sqrt[r  - x ]
    ------------------------------------------
                        2
    }),"\n"
    
    print linearize(%q{
                        2
            -b + Sqrt[ b  - 4 a c ]
            -----------------------
                    2 a
          }),"\n"
    end

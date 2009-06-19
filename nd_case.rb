



class Array
    def random
        self[rand(length)]
        end
    end


# =========================================================================================
#
puts "Implementation 1"
#
def nd_case(v,branches)
    (branches[branches.keys.select {|cond| cond === v}.random || :else]  || proc {}).call
    end
5.times {
    nd_case(7,
      Integer => proc { print "Integer\n" },
      "tree"  => proc { print "tree\n" },
      0..10   => proc { print "0..10\n" },
      7       => proc { print "7\n" },
      :else   => proc { print "No matches\n"}
      )
    }

# =========================================================================================
#
puts "Implementation 2"
#
def nd_case(v,*branches)
    branches = branches.inject({}) { |h,p| h.update p }
    (branches[branches.keys.select {|cond| cond === v}.random || :else]  || proc {}).call
    end
def nd_when(cond,&action)
    {cond => action}
    end
def nd_else(&action)
    {:else => action}
    end

5.times {
    nd_case(7,
      nd_when(Integer) do 
          print "Integer\n" 
          end,
      nd_when("tree")  do 
          print "tree\n" 
          end,
      nd_when(0..10)   do 
          print "0..10\n" 
          end,
      nd_when(7) do
          print "7\n"
          end,
      nd_else do
          print "No matches\n"
          end
      )
    }

# ==========================================================================================
#
puts "Implementation 3"
#
$nd_options = []
class Nd_cond
    def initialize(val)
        @val = val
        end
    def ===(other)
        (@val === other) and (callcc { |cont| $nd_options << cont; return false}; true)
        end
    def self.else
        return yield if $nd_options.empty?
        winner = $nd_options.random
        $nd_options = []
        winner.call
        end
    end
def nd_(x)
    Nd_cond.new(x)
    end

5.times {
    case 7
      when nd_(Integer): print "Integer\n"
      when nd_("tree"):  print "tree\n"
      when nd_(0..10):   print "0..10\n"
      when nd_(7):       print "7\n"
      else Nd_cond.else { print "No matches\n"}
      end
    }


# ==========================================================================================
#
puts "Implementation 4"
#
class A_wave_function
    attr_reader :possible_realities,:nested_wave_function,:modules_with_case_equ,:collapsed
    def initialize
        @nested_wave_function = $current_wave_function
        $current_wave_function = self
        @possible_realities = []
        @collapsed = false
        if @nested_wave_function
            @modules_with_case_equ = nested_wave_funtion.modules_with_case_equ
          else
            @modules_with_case_equ = {}
            ObjectSpace.each_object(Module) { |m|
                @modules_with_case_equ[m] = m.instance_method(:===) if m.instance_methods(false).include? "==="
                }
            @modules_with_case_equ.keys.each { |m|
                m.module_eval %Q{
                    def ===(other)
                        $current_wave_function.modules_with_case_equ[#{m}].bind(self).call(other) and (callcc { |cont| $current_wave_function.possible_realities << cont; return false}; true)
                        end
                    }
                }
            end
        end
    def else_block(block)
        possible_realities << block if possible_realities.empty?
        0
        end
    def collapse
        @collapsed = true
        @modules_with_case_equ.keys.each { |m|
            m.send(:define_method,:===,modules_with_case_equ[m])
            } unless nested_wave_function
        $current_wave_function = nested_wave_function
        (possible_realities.random || proc {}).call
        end
    def -(x)
        return x if collapsed
        collapse
        end
    end
def nondeterministic
    A_wave_function.new
    end
def deterministic(&block)
    $current_wave_function.else_block(block)
    end

5.times {
    nondeterministic-case 7
      when Integer: print "Integer\n"
      when "tree":  print "tree\n"
      when 0..10:   print "0..10\n"
      when 7:       print "7\n"
      else-deterministic { print "No matches\n" }
      end 
    }

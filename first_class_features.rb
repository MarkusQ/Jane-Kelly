
require "ostruct"
$features = {}
class A_feature < OpenStruct
    @@known_features = []
    def initialize(&block)
        @block = block
        super
        @@known_features << self
        end
    def install(context={})
        table.update context
        instance_eval &@block
        end
    def add_commandline_option(*params,&block)
        option_parser.on(*params,&block)
        end
    def self.from_a_file(file_name)
        load "features/#{file_name}"
        @@known_features.last
        end
    end


class Array
    def sum
        inject {|a,b| a+b }
        end
    end


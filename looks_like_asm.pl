#!/usr/bin/env perl

use constant StartY => 42;
use constant PATTERN_BUFFER => 0x7F800;

my %registers = {};
my %memory = {};

sub Register { 0.01*shift }
sub AX   {Register(1)}
sub BP   {Register(2)}
sub SI   {Register(3)}
sub get_operand {
    my $arg = shift;
    if (UNIVERSAL::isa($arg, 'ARRAY')) {
        my $x = @$arg[0];
        print join(",",$x) . " (should be 42.02)\n";
        return $memory{$x} || 12345
        }
      else {if ($arg > 0.0 && $arg < 1.0) {
        return $registers{$arg*100} || 12345
        }
      else {
        return $arg;
        }}
    }

sub set_operand {
    my $arg = shift;
    my $val = shift;
    if (UNIVERSAL::isa($arg, 'ARRAY')) {
        # Write to memory
        $memory{$arg} = $val;
        print "set " . $arg . ", " . $val . "\n";
        }
      else {if ($arg > 0.0 && $arg < 1.0) {
        # Store in register
        $registers{$arg*100} = $val;
        print "set registers{" . $arg*100 . "}, " . $val . "\n";
        }
      else {
        die "Can't set anything but registers and memory"
        }}
    }

sub MOV  { set_operand(@_[0],get_operand(@_[1])) }
sub ADD  { set_operand(@_[0],get_operand(@_[0]) + get_operand(@_[1])) }
sub AND  { set_operand(@_[0],get_operand(@_[0]) & get_operand(@_[1])) }


    MOV AX, [BP + StartY]        ; # of bytes offset
    MOV SI, AX                   ;
    AND AX, 0x03                 ;
    ADD SI, PATTERN_BUFFER       ;



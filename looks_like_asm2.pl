#!/usr/bin/env perl

use strict;

my $AX = 0;
my $SI = 0;

sub MOV {       print "MOV\n"; my $partial = shift; $partial->(shift); }

sub AX 
{
        print "AX\n";
        return sub { 
                return $AX if( scalar(@_) == 0 );
                $AX = interpret(shift, $AX);
        } 
}


sub SI 
{
        print "SI\n";
        return sub { 
                return $SI if( scalar(@_) == 0 );
                $SI = interpret(shift, $SI);
        } 
}

sub interpret
{
        my $arg = shift; 
        my $default = shift;

        if( ref($arg) eq 'CODE' )
        {
                return $arg->();
        }
        elsif ( ref($arg) eq 'ARRAY' )
        {
                return @$arg[0];
        }
        else # Assume scalar.
        {
                return $default if $arg eq "";

                return $arg;
        }

}

sub AND 
{ 
        print "AND\n"; 
        my $partial = shift;
        $partial->( $partial->() & shift );
}

#    MOV AX, [BP + StartY]        ; # of bytes offset
        MOV AX, [125];
        print "AX is now: ", $AX, "\n";

        #    MOV SI, AX                   ;
        MOV SI, AX;
        print "SI is now: ", $SI, "\n"; 
        print "AX is now: ", $AX, "\n";

#    AND AX, 0x03                 ;
        AND AX, 0x03;

        print "AX is now: ", $AX, "\n"; 

#    ADD SI, PATTERN_BUFFER       ;





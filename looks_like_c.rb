#!/usr/bin/env ruby
def method_missing(msg,*args, &block)
    (proc &block).call if block_given?
    end


#include <stdio.h>
#include <stdlib.h>

int main(void) {
  puts("Hello World!");
  int i = 7,n = 999999;
  printf("Did you know that %i is %i times %i?\n",n,i,n/i);
  return 0;
  }

from guard import *

known_fibs = {0:1,1:1}

def foo(n):
    return known_fibs,get(n,None)

@when("n in known_fibs")
def fib(**kargs):
    return known_fibs[kargs['n']]

@when()
def fib(**kargs):
    global known_fibs
    n = kargs['n']
    known_fibs[n] = fib(n=(n-1)) + fib(n=(n-2))
    return known_fibs[n]

print fib(n=20)

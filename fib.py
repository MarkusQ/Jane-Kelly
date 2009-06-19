from guard import *

@when("n in (0, 1)")
def fib(**kargs):
	return 1

@when()
def fib(**kargs):
    n = kargs['n']
    return fib(n=(n-1)) + fib(n=(n-2))

print fib(n=20)


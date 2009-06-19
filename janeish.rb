
factorial(x) := 
    case x
       0: 1
       1: 1
       else x*factorial(x-1)

(0)! := 1
(1)! := 1
(x)! := x*(x-1)!

memoize factorial
memoize !

memoize(f) := 
    in f's scope 
        f's name (*args)  := memoized_values[f][args] ||= f(*args)



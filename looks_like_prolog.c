
#define father(child,dad) 
#define mother(child,mom) 
#define parent(child,p) 
#define grandmother(child,grandma) 
#define when
#define and
#define or
#define find goal = 



father(mary,bob)
mother(mary,sue)
father(don,bill)
mother(don,beth)
father(pat,don)
mother(pat,mary)

parent(X,Y) when 
    mother(X,Y) or 
    father(C,Y)

grandmother(X,Y) when 
    parent(X,A) and 
    mother(A,Y)

find grandmother(pat,Who)

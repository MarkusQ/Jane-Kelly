

def coroutine(func):
    def start(*args,**kwargs):
        cr = func(*args,**kwargs)
        cr.next()
        return cr
    return start

def integers_up_to(n,user):
    i = 1
    while i < n:
         user.send(i)
         i = i + 1

@coroutine
def divisable_by(n,user):
    while True:
        i = (yield)
        if i % n == 0:
            user.send(i)

total = 0
@coroutine
def sum_them_up():
    global total
    highest_seen = 0
    while True:
         i = (yield)
         if i > highest_seen:
             total = total + i
         highest_seen = i

@coroutine
def broadcast(targets):
    while True:
        item = (yield)
        for target in targets:
            target.send(item)

sum_them = sum_them_up()
integers_up_to(1000,
    broadcast([divisable_by(3,sum_them),
               divisable_by(5,sum_them)])
        )
print total


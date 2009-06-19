class Guard:
  dispatch_table = []

  @classmethod
  def register(cls, func, condition):
    cls.dispatch_table += [(func, condition)]
  @classmethod
  def satisfies_predicate(cls, predicate, params):
    import sys
    return eval(predicate, sys._getframe(2).f_globals, params) if predicate else True
def when(condition=""):
  def decorator(func):
    Guard.register(func, condition)
    def dispatcher(**args):
      possibles = [method for (method, predicate) in Guard.dispatch_table if method.__name__ == func.__name__ and Guard.satisfies_predicate(predicate, args)]
      return possibles[0](**args) if possibles else func(**args)
    return dispatcher
  return decorator

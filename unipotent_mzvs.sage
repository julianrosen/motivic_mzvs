load('read_data_mine.sage')
try:
    load('algebra_class.sage')
except IOError:
    load('../algebra_class/algebra_class.sage')
from types import MethodType

def UnipotentMzvs(weight=12):
    """
    Returns the ring of motivic multiple zeta values (with data up through weight)
    """
    basis,D = read_data_mine(weight)
    spot = basis.index((2,))
    for x in D:
        for y in D[x].keys():
            if y[spot] == 0:
                D[x][y[:spot]+y[spot+1:]] = D[x][y]
            D[x].pop(y)
    basis.pop(spot)
                
    n = len(basis)
    name = "The ring of unipotent multiple zeta values"
    unit = tuple(0 for b in basis)
    data = {'basis':basis,'D':D}
    mul = lambda L1,L2:{tuple([x+y for x,y in zip(L1,L2)]):1}
    order = lambda s:(sum(x*sum(y) for x,y in zip(s,basis)))
    def rep(s,brace=False):
        T = ""
        ss = ""
        for n,e in enumerate(s):
            if e == 0:
                continue
            ss = "zeta^u" + print_tuple(basis[n])
            if e >= 2:
                if brace:
                    ss = ss + "^{%i}"%e
                else:
                    ss = ss + "^%i"%e
            if T != "":
                T = T + "*"
            T = T + ss
        return T
    tex = lambda s: rep(s,brace=True).replace('zeta^u','\\zeta^{\mathfrak{u}}').replace('*','')
    self_tex = r'\mathcal{P}^{\mathfrak{u}}'
    R = Algebra(name=name,base=QQ,unit=unit,mul=mul,order=order,data=data,rep=rep,tex=tex,self_tex=self_tex)
    def mzv(*s):
        if len(s) >= 1 and s[0] <= 1:
            raise ValueError("First argument needs to be at least 2")
        C = R.data['D']
        return R(get_value(C,s))
    setattr(R, "zeta", mzv)
    setattr(R, "L",lambda n:R(1)) # The unipotent Lefschetz period is 1
    return R
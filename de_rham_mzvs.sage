load('read_data_mine.sage')
try:
    load('algebra_class.sage')
except IOError:
    load('../algebra_class/algebra_class.sage')
from types import MethodType

def DeRhamMzvs(weight=12):
    """
    Returns the ring of de Rham motivic periods of MT(Z) (with data up through weight)
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
    name = "The ring of de Rham motivic periods of MT(Z)"
    unit = tuple(0 for b in basis) + (0,)
    data = {'basis':basis,'D':D}
    mul = lambda L1,L2:{tuple([x+y for x,y in zip(L1,L2)]):1}
    order = lambda s:(sum(x*sum(y) for x,y in zip(list(s),[(1,)]+basis)))
    def rep(s,brace=False):
        T = ""
        ss = ""
        for n,e in enumerate(s):
            if e == 0:
                continue
            ss = ("zeta^dr" + print_tuple(basis[n-1])) if n>=1 else "L^dr" if e==1 else "(L^dr)"
            if e != 1:
                if brace:
                    ss = ss + "^{%i}"%e
                else:
                    ss = ss + "^%i"%e
            if T != "":
                T = T + "*"
            T = T + ss
        return T
    tex = lambda s: rep(s,brace=True).replace('zeta^dr','\\zeta^{\mathfrak{dr}}').replace('*','').replace('L^dr',r'\mathbb{L}^{\mathfrak{dr}}')
    self_tex = r'\mathcal{P}^{\mathfrak{dr}}'
    R = Algebra(name=name,base=QQ,unit=unit,mul=mul,order=order,data=data,rep=rep,tex=tex,self_tex=self_tex)
    def mzv(*s):
        if len(s) >= 1 and s[0] <= 1:
            raise ValueError("First argument needs to be at least 2")
        C = R.data['D']
        D = get_value(C,s)
        return R({(0,)+x:D[x] for x in D})
    setattr(R, "zeta", mzv)
    setattr(R, "L",lambda n:R((n,)+tuple(0 for b in basis)))
    return R
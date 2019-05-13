load('read_alternating.sage')
try:
    load('algebra_class.sage')
except IOError:
    load('../algebra_class/algebra_class.sage')

def EulerSums(weight=8):
    """
    Returns the ring of motivic multiple zeta values (with data up through weight)
    """
    basis,D = read_alternating(weight)
    n = len(basis)
    name = "The ring of Euler sums"
    unit = tuple(0 for b in basis)
    data = {'basis':basis,'D':D}
    mul = lambda L1,L2:{tuple([x+y for x,y in zip(L1,L2)]):1}
    order = lambda s:(sum(x*sum(abs(q) for q in y) for x,y in zip(s,basis)))
    def rep(s,brace=False):
        T = ""
        ss = ""
        log_index = basis.index((-1,))
        for n,e in enumerate(s):
            if e == 0:
                continue
            if n == log_index:
                ss = "log(2)"
            else:
                ss = "zeta" + print_tuple(basis[n])
            if e >= 2:
                if brace:
                    ss = ss + "^{%i}"%e
                else:
                    ss = ss + "^%i"%e
            if T != "":
                T = T + "*"
            T = T + ss
        return T
    tex = lambda s: rep(s,brace=True).replace('zeta',r'\zeta').replace('*','').replace("log(2)",r"\log(2)")
    self_tex = r'\mathcal{E}'
    R = Algebra(name=name,base=QQ,unit=unit,mul=mul,order=order,data=data,rep=rep,tex=tex,self_tex=self_tex)
    def mzv(*s):
        if len(s) >= 1 and s[0] == 1:
            raise ValueError("First argument cannot be 1")
        C = R.data['D']
        return R(get_value(C,s))
    setattr(R, "zeta", mzv)
    return R
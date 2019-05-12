from os.path import join, isfile, isdir, realpath, dirname
from os import makedirs, getcwd
import random
import bz2
from collections import defaultdict
from copy import copy

def dual(s):
    """
    Returns the Hoffman dual of s
    """
    ss = tuple_to_bin(s)
    ssd = tuple(1-x for x in ss[::-1])
    return bin_to_tuple(ssd)

def get_value(D,s):
    """
    Read off value at s from D
    """
    if s in D:
        return D[s]
    else:
        sd = dual(s)
        if sd in D:
            return D[dual(s)]
        else:
            raise ValueError("This MZV was not found in table.")


def bin_to_tuple(s):
    """
    Returns the tuple corresponding to 0-1 tuple s
    """
    T = [0]
    for x in s:
        T[-1] += 1
        if x == 1:
            T.append(0)
    return tuple(T[:-1])

def string_to_bin(s):
    """
    Returns a 0-1 tuple coming from string s
    """
    L = s.split('(')[1].split(')')[0].split(',')
    return tuple(Integer(x) for x in L)

def string_to_tuple(s):
    """
    Returns a tuple corresponding to 0-1 tuple in string s
    """
    return bin_to_tuple(string_to_bin(s))

def tuple_to_bin(s):
    T = []
    for x in s:
        for _ in range(x-1):
            T.append(0)
        T.append(1)
    return tuple(T)

def read_until(f,s):
    """Reads off a chunk of a file"""
    T,L = "",""
    while s not in L:
        L = f.readline()
        T = T + L
        if L == "":
            break
    return T

def strip(s):
    """
    Strips crap out of s
    """
    for c in ['\t',' ','\n',';']:
        s = s.replace(c,'')
    return s

def add_entry(D,LL,basis,basis_file):
    """
    Adds an entry to D coming from string s from data mine
    """
    L = strip(LL)
    s = string_to_tuple(L)
    if '=' not in L:
        print L
        raise Exception
    L = L.split('=')[1]
    L = L.split('+')
    T = []
    for q in L:
        for i,w in enumerate(q.split('-')):
            if w == '':
                continue
            if i == 0:
                T.append(w)
            else:
                T.append('-'+w)
    T = [x if 'z' not in x[:2] else '1*'+x if x[0]!='-' else '-1*'+x[1:] for x in T]
    DD = {}
    for x in T:
        L = x.split('*')
        coefficient = Rational(L[0])
        w = [0 for _ in range(len(basis))]
        for q in L[1:]:
            b = str(q)
            if '^' not in b:
                b = b + '^1'
            z = b.split('^')
            w[basis_file.index(z[0])] += Integer(z[1])
        DD[tuple(w)] = coefficient
    D[s] = dict(DD)
    return None

def read_data_mine(max_weight):
    with file("data_mine\\hexc.h",'r') as a:
        # Skip to correct place in file
        for _ in range(332):
            a.readline()

        # Read off basis elements
        basis = []
        basis_file = []

        D = {}

        # Read off formulas through weight 10
        while True:
            L = a.readline()
            if L[:5] == "#case":
                current_weight = Integer(L[5:])
                if current_weight > max_weight:
                    break
                continue
            if L[:6] == "#break":
                continue
            assert L[:2] == "id"
            basis.append(string_to_tuple(L))
            basis_file.append(L.split("= ")[1][:-2])

        for current_weight in range(2,min(max_weight+1,11)):
            while "#procedure mzv%i"%current_weight not in L:
                L = a.readline()
                if L == "":
                    raise Exception
            while "Fill" not in L:
                L = a.readline()
            while "Fill" in L:
                while ';' not in L:
                    L = L + a.readline()
                try:
                    add_entry(D,L,basis,basis_file)
                except:
                    print L
                L = a.readline()

        a.close()
    for current_weight in range(11,max_weight+1):
        filename = "data_mine\\mzv%i.prc.bz2" % current_weight
        with bz2.BZ2File(filename, "rU") as a:
            L = ""
            while "Fill" not in L:
                L = a.readline()
            while "Fill" in L:
                while ';' not in L:
                    L = L + a.readline()
                try:
                    add_entry(D,L,basis,basis_file)
                except:
                    print L
                L = a.readline()
            a.close()
    D[()] = {tuple(0 for _ in basis):1}
    return basis,D
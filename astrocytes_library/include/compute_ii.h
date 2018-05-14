#pragma once

#include <cmath>
#include <float.h>

using namespace std;

typedef unsigned int basetype;

typedef unsigned long counttype;

#define maxval(N) (~((~0x0)<<(N)))  // = 2^N - 1

// Nx  - number of bits in x
// Nxy - number of bits in (x,y) pair

double compute_ii(counttype * FRx, counttype * FRxy, counttype Mx, counttype Mxy, basetype &MIB, int Nx, int Nxy);
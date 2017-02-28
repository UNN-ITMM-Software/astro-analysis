#ifndef VERTEX_H
#define VERTEX_H

#include "declaration.h"

struct vertex 
{
    int key;
    ushort start, finish;
    inline ushort len() const { return finish - start + 1; };
};

#endif

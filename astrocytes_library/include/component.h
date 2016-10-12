#ifndef COMPONENT_H
#define COMPONENT_H

#include "vertex.h"

struct component : vertex
{	
	int max_projection;
	bool good{ true };
};

#endif

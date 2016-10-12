#include "clusters.h"
#include <boost/foreach.hpp>

Neighbors Clusters::findNeighbors(PointId pid, double threshold)
{
	Neighbors ne;
	for (unsigned int j=0; j < _sim.size1(); j++)
	{
		if 	((pid != j ) && (_sim(pid, j)) > threshold)
		{
			ne.push_back(j);
		}
	}
	return ne;
};

// single point output
std::ostream& operator<<(std::ostream& o, const ClusterPoint& p)
{
	o << "{";
	BOOST_FOREACH(ClusterPoint::value_type x, p)
	{
		o << "" << x;
	}
	o << "} ";
	return o;
}

// single cluster output
std::ostream& operator<<(std::ostream& o, const Cluster& c)
{
	o << "[ ";
	BOOST_FOREACH(PointId pid, c)
	{
		o << " " << pid;
	}
	o << " ]";

	return o;
}

// clusters output
std::ostream& operator<<(std::ostream& o, const Clusters& cs)
{
	ClusterId cid = 1;
	BOOST_FOREACH(Cluster c, cs._clusters)
	{
		o << "c(" << cid++ << ")=";

		BOOST_FOREACH(PointId pid, c)
		{
			o << cs._ps[pid];
		}
		o << std::endl;
	}
	return o;
}


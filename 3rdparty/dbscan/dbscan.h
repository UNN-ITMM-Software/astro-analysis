#ifndef DBSCAN_H
#define DBSCAN_H

#include <vector>
#include <boost/numeric/ublas/matrix.hpp>

#include "clusters.h"

class DBSCAN : public Clusters
{
public:
	DBSCAN(Points & ps, double eps, unsigned int minPts) : 
		Clusters(ps), _eps(eps), _minPts(minPts)
	{
		_noise.resize(ps.size(), false);
		_visited.resize(ps.size(), false);
	};

	// 
	// The clustering algo
	//
	void run_cluster() ;

private:

	// eps radiuus
	// Two points are neighbors if the distance 
	// between them does not exceed threshold value.
	double _eps;

	//minimum number of points
	unsigned int _minPts;

	// noise vector
	std::vector<bool> _noise;

	// noise vector
	std::vector<bool> _visited;
};

#endif
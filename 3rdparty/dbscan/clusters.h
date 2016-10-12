#ifndef CLUSTERS_H
#define CLUSTERS_H

#include <vector>
#include <cmath>
#include <iostream>
#include <boost/numeric/ublas/matrix.hpp>
#include <boost/numeric/ublas/vector.hpp>
#include <boost/foreach.hpp>
#include "distance.h"

// a single point is made up of vector of doubles
typedef boost::numeric::ublas::vector<double> ClusterPoint;
typedef std::vector<ClusterPoint> Points;

typedef unsigned int ClusterId;
typedef unsigned int PointId;	

// a cluster is a vector of pointid
typedef std::vector<PointId> Cluster;
// a set of Neighbors is a vector of pointid
typedef std::vector<PointId> Neighbors;

class Clusters
{
public:
	Clusters (Points & ps) : _ps(ps) 
	{
		_pointId_to_clusterId.resize(_ps.size(), 0);
	};

	// compute similarity
	template <typename Distance_type>
	void computeSimilarity(Distance_type & d)
	{
		unsigned int size = _ps.size();
		_sim.resize(size, size, false);
		for (unsigned int i=0; i < size; i++)
		{
			for (unsigned int j=i+1; j < size; j++)
			{
				_sim(j, i) = _sim(i, j) = d.similarity(_ps[i], _ps[j]);
			}
		}
	};

	Neighbors findNeighbors(PointId pid, double threshold);
	
	std::vector<ClusterId> getClusterIds() const
	{
		return _pointId_to_clusterId;
	}
protected:
	// the collection of points we are working on
	Points& _ps;
		
	// mapping point_id -> clusterId
	std::vector<ClusterId> _pointId_to_clusterId;

	// the collection of clusters
	std::vector<Cluster> _clusters;

	// simarity_matrix
	boost::numeric::ublas::matrix<double> _sim;

	friend std::ostream& operator << (std::ostream& o, const Clusters& c);
};

#endif

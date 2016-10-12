#include "dbscan.h"
#include <boost/foreach.hpp>

void DBSCAN::run_cluster() 
{
		
	ClusterId cid = 1;
	// foreach pid
	for (PointId pid = 0; pid < _ps.size(); pid++)
	{
		// not already visited
		if (!_visited[pid]){  
				
			_visited[pid] = true;

			// get the neighbors
			Neighbors ne = findNeighbors(pid, _eps);

			// not enough support -> mark as noice
			if (ne.size() < _minPts)
			{
				_noise[pid] = true;
			} 
			else 
			{
				// Add p to current cluster
				Cluster c;              // a new cluster
				c.push_back(pid);   	// assign pid to cluster
				_pointId_to_clusterId[pid]=cid;

				// go to neighbors
				for (unsigned int i = 0; i < ne.size(); i++)
				{
					PointId nPid = ne[i];

					// not already visited
					if (!_visited[nPid])
					{
						_visited[nPid] = true;

						// go to neighbors
						Neighbors ne1 = findNeighbors(nPid, _eps);

						// enough support
						if (ne1.size() >= _minPts)
						{
							// join
							BOOST_FOREACH(Neighbors::value_type n1, ne1)
							{
								// join neighbord
								ne.push_back(n1); 
							}
						}
					}

					// not already assigned to a cluster
					if (!_pointId_to_clusterId[nPid])
					{
						c.push_back(nPid);
						_pointId_to_clusterId[nPid]=cid;
					}
				}

				_clusters.push_back(c);
				cid++;
			}
		} // if (!visited
	} // for
}

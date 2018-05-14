#include <gtest.h>
#include "dbscan.h"
#include "distance.h"
#include "vertex.h"

TEST(dbscan_test, check_graph_verteces)
{
	Points ps;
	const int num_points = 27, dims = 1;
	for (int i = 0; i < num_points; i++)
	{
		ClusterPoint p(dims);
		ps.push_back(p);
	}
	ps[0](0) = 0; ps[1](0) = 1; ps[2](0) = 3;
	ps[3](0) = 5; ps[4](0) = 6; ps[5](0) = 7;
	ps[6](0) = 8; ps[7](0) = 9; ps[8](0) = 10;
	ps[9](0) = 11; ps[10](0) = 12; ps[11](0) = 19;
	ps[12](0) = 20; ps[13](0) = 21; ps[14](0) = 22;
	ps[15](0) = 23; ps[16](0) = 24; ps[17](0) = 25;
	ps[18](0) = 30; ps[19](0) = 31; ps[20](0) = 32;
	ps[21](0) = 33; ps[22](0) = 34; ps[23](0) = 35;
	ps[24](0) = 36; ps[25](0) = 37; ps[26](0) = 38;

	// eps = 1.0 / distance(x1, x2);
	// min_points - minimum number of points
	DBSCAN clusters(ps, 0.3333, 3);

	// build similarity  matrix
	Distance<Euclidean<ClusterPoint> > d;
	clusters.computeSimilarity(d);

	// run clustering
	clusters.run_cluster();
	std::vector<ClusterId> clusterIds = clusters.getClusterIds();
	vector<vertex> res;
	int num = 0;
	res.push_back({ num, ushort(ps.front()(0)), ushort(-1) });
	for (int k = 0; k < (int)clusterIds.size() - 1; k++)
	{
		if (clusterIds[k] != clusterIds[k + 1])
		{
			res.back().finish = ushort(ps[k](0));
			res.push_back({ (int)(num + res.size()),
				ushort(ps[k + 1](0)), ushort(-1) });
		}
	}
	res.back().finish = ps.back()(0);
	ASSERT_EQ(res.size(), 3);
	ASSERT_EQ(res[0].start, 0); ASSERT_EQ(res[0].finish, 12);
	ASSERT_EQ(res[1].start, 19); ASSERT_EQ(res[1].finish, 25);
	ASSERT_EQ(res[2].start, 30); ASSERT_EQ(res[2].finish, 38);
}

TEST(dbscan_test, check_graph_verteces_100_442)
{
	Points ps;
	const int num_points = 64, dims = 1;
	for (int i = 0; i < num_points; i++)
	{
		ClusterPoint p(dims);
		ps.push_back(p);
	}
	int idx = 0;
	for (int i = 84; i <= 94; i++)
	{
		ps[idx++](0) = i;
	}
	for (int i = 127; i <= 148; i++)
	{
		ps[idx++](0) = i;
	}
	for (int i = 151; i <= 152; i++)
	{
		ps[idx++](0) = i;
	}
	for (int i = 155; i <= 157; i++)
	{
		ps[idx++](0) = i;
	}
	ps[idx++](0) = 179;
	ps[idx++](0) = 181;
	for (int i = 292; i <= 297; i++)
	{
		ps[idx++](0) = i;
	}
	for (int i = 301; i <= 302; i++)
	{
		ps[idx++](0) = i;
	}
	for (int i = 306; i <= 307; i++)
	{
		ps[idx++](0) = i;
	}
	for (int i = 310; i <= 320; i++)
	{
		ps[idx++](0) = i;
	}
	for (int i = 332; i <= 334; i++)
	{
		ps[idx++](0) = i;
	}

	// eps = 1.0 / distance(x1, x2);
	// min_points - minimum number of points
	DBSCAN clusters(ps, 0.3333, 3);

	// build similarity  matrix
	Distance<Euclidean<ClusterPoint> > d;
	clusters.computeSimilarity(d);

	// run clustering
	clusters.run_cluster();
	std::vector<ClusterId> clusterIds = clusters.getClusterIds();
	vector<vertex> res;
	int num = 0;
	int k = 0;
	for (; k < (int)clusterIds.size() - 1; k++)
	{
		if (clusterIds[k] != 0)
		{
			res.push_back({ num, ushort(ps[k](0)), ushort(-1) });
			break;
		}
	}
	for (; k < (int)clusterIds.size() - 1; k++)
	{
		if (clusterIds[k] != clusterIds[k + 1])
		{
			res.back().finish = ushort(ps[k](0));
			for (; k <(int)clusterIds.size() - 1; k++)
			{
				if (clusterIds[k + 1] != 0)
				{
					res.push_back({ (int)(num + res.size()),
						ushort(ps[k + 1](0)), ushort(-1) });
					break;
				}
			}
		}
	}
	if (clusterIds[clusterIds.size() - 1] != 0)
	{
		res.back().finish = ps.back()(0);
	}
}

TEST(dbscan_test, check_graph_verteces_272_478)
{
	Points ps;
	const int num_points = 42, dims = 1;
	for (int i = 0; i < num_points; i++)
	{
		ClusterPoint p(dims);
		ps.push_back(p);
	}
	int idx = 0;
	for (int i = 7; i <= 9; i++)
	{
		ps[idx++](0) = i;
	}
	for (int i = 65; i <= 75; i++)
	{
		ps[idx++](0) = i;
	}
	for (int i = 81; i <= 86; i++)
	{
		ps[idx++](0) = i;
	}
	for (int i = 89; i <= 92; i++)
	{
		ps[idx++](0) = i;
	}
	for (int i = 303; i <= 316; i++)
	{
		ps[idx++](0) = i;
	}
	for (int i = 330; i <= 333; i++)
	{
		ps[idx++](0) = i;
	}
	// eps = 1.0 / distance(x1, x2);
	// min_points - minimum number of points
	DBSCAN clusters(ps, 0.3333, 3);

	// build similarity  matrix
	Distance<Euclidean<ClusterPoint> > d;
	clusters.computeSimilarity(d);

	// run clustering
	clusters.run_cluster();
	std::vector<ClusterId> clusterIds = clusters.getClusterIds();
	vector<vertex> res;
	int num = 0;
	int k = 0;
	for (; k < (int)clusterIds.size() - 1; k++)
	{
		if (clusterIds[k] != 0)
		{
			res.push_back({ num, ushort(ps[k](0)), ushort(-1) });
			break;
		}
	}
	for (; k < (int)clusterIds.size() - 1; k++)
	{
		if (clusterIds[k] != clusterIds[k + 1])
		{
			res.back().finish = ushort(ps[k](0));
			for (; k <(int)clusterIds.size() - 1; k++)
			{
				if (clusterIds[k + 1] != 0)
				{
					res.push_back({ (int)(num + res.size()),
						ushort(ps[k + 1](0)), ushort(-1) });
					break;
				}
			}
		}
	}
	if (clusterIds[clusterIds.size() - 1] != 0)
	{
		res.back().finish = ps.back()(0);
	}
}

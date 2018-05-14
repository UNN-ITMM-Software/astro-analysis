#include <gtest.h>
#include "auxiliaries.h"
#include "astrocyte.h"

void calc_vertex(const vector<ushort> &clusters,
	const std::vector<ushort> &active, int num, vector<vertex> &res)
{
	res.push_back({ num, active.front(), ushort(-1) });
	for (int k = 0; k < (int)clusters.size() - 1; k++)
	{
		if (clusters[k] != clusters[k + 1])
		{
			res.back().finish = active[k];
			res.push_back({ (int)(num + res.size()),
				active[k + 1], ushort(-1) });
		}
	}
}

TEST(dbscan_test_2, check_graph_verteces)
{
	vector <ushort> active = {
		0, 1, 3, 5, 6, 7, 8, 9, 10, 11, 12, 19, 20, 21, 22, 23, 24, 25, 30, 31, 32, 33, 34, 35, 36, 37, 38
	};
	
	// eps = 1.0 / distance(x1, x2);
	// min_points - minimum number of points
	
	vector <ushort> clusters = dbscan(active, 3, 3);
	vector <vertex> res;
	calc_vertex(clusters, active, 0, res);

	res.back().finish = active.back();
	ASSERT_EQ(res.size(), 3);
	ASSERT_EQ(res[0].start, 0); ASSERT_EQ(res[0].finish, 12);
	ASSERT_EQ(res[1].start, 19); ASSERT_EQ(res[1].finish, 25);
	ASSERT_EQ(res[2].start, 30); ASSERT_EQ(res[2].finish, 38);
}
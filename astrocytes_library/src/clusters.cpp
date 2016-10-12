#include "astrocyte.h"

#ifdef DUMP_DATA
#include "utilities.h"
#endif

void astrocyte::active_mask(boost::dynamic_bitset<> * mask_p)
{
	astro_log.set_info(L"Create mask of active pixels.");
	for (int t = 0; t < current->nt; t++)
	{
		for (int i = 0; i < current->n; i++)
		{
			for (int j = 0; j < current->m; j++) 
			{
				uchar cur = current->cell(t, i, j);
				if (cur < 1) continue;
				mask[(t * current->n + i) * current->m + j] = true;
				mask_p[i * current->m + j].set(t);
			}
		}
	}
#ifdef DUMP_DATA
	Utilities::save_activity_mask(DUMP_PATH, mask_p, 
		current->n, current->m, current->nt);
#endif
	astro_log.set_info(L"~Create mask of active pixels.");
}

void astrocyte::find_activity_moments(boost::dynamic_bitset<> * &mask_p,
	int i, int j, std::vector<ushort> &active)
{
	boost::dynamic_bitset<> mask_square(current->nt);
	mask_square.reset();
	for (int x = i; x < i + segm.a; x++)
	{
		for (int y = j; y < j + segm.a; y++)
		{
			mask_square |= mask_p[x * current->m + y];
		}
	}
	for (int t = 0; t < current->nt; t++)
	{
		if (mask_square.test(t))
		{
			active.push_back(t);
		}
	}
}

void astrocyte::find_activity_moments(boost::dynamic_bitset<> * &mask_p,
	int i, int j, Points &active)
{	
	boost::dynamic_bitset<> mask_square(current->nt);
	mask_square.reset();
	for (int x = i; x < i + segm.a && x < current->n - segm.a + 1; x++)
	{
		for (int y = j; y < j + segm.a && y < current->m - segm.a + 1; y++)
		{
			mask_square |= mask_p[x * current->m + y];
		}
	}
	const int dim = 1;
	for (int t = 0; t < current->nt; t++)
	{
		if (mask_square.test(t))
		{
			ClusterPoint p(dim);
			p(0) = t;
			active.push_back(p);
		}
	}
}

void astrocyte::create_graph_vertex(const vector<ushort> &clusters,
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
	res.back().finish = active.back();
}

void astrocyte::create_graph_vertex(const vector<ClusterId> &clusterIds,
	const Points &ps, int num, vector<vertex> &res)
{
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

int astrocyte::clustering_intervals(boost::dynamic_bitset<> * &mask_p)
{
	astro_log.set_info(L"Clustering intervals by t in each window a * a.");	
	int num = 0; // number of all segments
	for (int i = 0; i < current->n - segm.a + 1; i++)
	{
		for (int j = 0; j < current->m - segm.a + 1; j++) 
		{
			int ind = i * current->m + j;
			if (!mask_p[ind].any()) continue;			
			//std::vector<ushort> active; // all active moments in square
			Points active;
			//find_activity_moments(mask_p, i, j, active);
			find_activity_moments(mask_p, i, j, active);

			// get clusters with algo DBSCAN
			//vector<ushort> clusters = dbscan(active, segm.min_points, segm.eps);
			DBSCAN clusters(active, 1.0 / segm.eps, segm.min_points);
			Distance<Euclidean<ClusterPoint> > d;
			clusters.computeSimilarity(d);
			clusters.run_cluster();

			// get all start/finish of clusters and add it into res
			//create_graph_vertex(clusters, active, num, res);
			vector<ClusterId> clusterIds = clusters.getClusterIds();
			vector<vertex> res;
			create_graph_vertex(clusterIds, active, num, res);

			graph[ind] = res;
			num += (int)res.size();
		}
	}
#ifdef DUMP_DATA
	Utilities::save_graph_verteces(graph, current->n, current->m, DUMP_PATH);
#endif
	astro_log.set_info(L"~Clustering intervals by t in each window a * a.");
	return num;
}

void astrocyte::find_active_points(int frame_idx)
{
	for (int i = 0; i < current->n - segm.a + 1; i++)
	{
		for (int j = 0; j < current->m - segm.a + 1; j++)
		{
			int ind = i * current->m + j;
			if (pos[ind] < graph[ind].size() &&
				graph[ind][pos[ind]].finish < frame_idx)
			{
				pos[ind]++;
			}
		}
	}
}

void astrocyte::union_frame_points(boost::disjoint_sets<int *, int *> &ds,
	int frame_idx)
{
	for (int i = 0; i < current->n - segm.a + 1; i++)
	{
		for (int j = 0; j < current->m - segm.a + 1; j++)
		{
			int ind = i * current->m + j;
			if (pos[ind] >= graph[ind].size() ||
				graph[ind][pos[ind]].start > frame_idx) continue;
			ushort be1 = graph[ind][pos[ind]].start,
				   en1 = graph[ind][pos[ind]].finish; // first segment
			for (int x = i; x < i + segm.a && x < current->n - segm.a + 1; x++)
			{
				for (int y = j; y < j + segm.a && y < current->m - segm.a + 1; y++)
				{
					int ind2 = x * current->m + y;
					if (pos[ind2] >= graph[ind2].size() ||
						graph[ind2][pos[ind2]].start > frame_idx) continue;
					ushort be2 = graph[ind2][pos[ind2]].start,
						   en2 = graph[ind2][pos[ind2]].finish; // second segment

					int s = (segm.a - x + i) * (segm.a - y + j);
					int len = max(min(en2, en1) - max(be2, be1), 0);
					
					// threshold by area and time
					if (s > (segm.a * segm.a - s) * segm.thr_area &&
						(len > max(en1 - be1, en2 - be2) * segm.thr_time ||
							(graph[ind2][pos[ind2]].len() <= segm.min_duration ||
								graph[ind][pos[ind]].len() <= segm.min_duration)))
							/*(graph[ind2][pos[ind2]].len() == 1 ||
								graph[ind][pos[ind]].len() == 1)))*/
					{
						ds.union_set(graph[ind][pos[ind]].key,
							graph[ind2][pos[ind2]].key); // connect vertices of segments
					}
				}
			}
		}
	}
}

int astrocyte::set_component_idx(boost::disjoint_sets<int *, int *> &ds, 
	int num)
{
	int *id_components = new int[num];
	std::memset(id_components, false, num * sizeof(int));
	for (int i = 0; i < num; i++)
	{
		id_components[ds.find_set(i)] = true;
	}
	int cnt = 0;
	for (int i = 0; i < num; i++)
	{
		if (id_components[i]) cnt++;
	}
	delete[]id_components;
	
	for (int i = 0; i < current->n - segm.a + 1; i++)
	{
		for (int j = 0; j < current->m - segm.a + 1; j++)
		{
			for (auto & v : graph[i * current->m + j])
			{
				v.key = ds.find_set(v.key);
			}
		}
	}
	return cnt;
}

int astrocyte::union_clusters(int num)
{
	// union clusters into components
	astro_log.set_info (L"Union clusters into components.");
	int *rank = new int[num], *parent = new int[num]; // for disjoint_set
	boost::disjoint_sets<int *, int *> ds = 
		boost::disjoint_sets<int *, int *>(rank, parent);
	for (int i = 0; i < num; i++)
	{
		ds.make_set(i);
	}

	std::memset(pos, 0, current->nm * sizeof(ushort));
	for (int t = 0; t < current->nt; t++)
	{
		// update pos (index of segment with end greater than t)
		find_active_points(t);

		// union intersected by time and overlapped by area components
		union_frame_points(ds, t);
	}
	int cnt = set_component_idx(ds, num);
	delete []rank;
	delete []parent;
	calc_flag.components = true;
#ifdef DUMP_DATA
	Utilities::save_graph_verteces(graph, current->n, current->m, DUMP_PATH);
#endif
	astro_log.set_info (L"~Union clusters into components.");
	return cnt;
}

vector<component> astrocyte::get_events_info(bool duration, 
	bool max_projection)
{
	// calculate for each component start and finish time, 
	// max projection, bounding box
	astro_log.set_info(L"Calculating events information.");
	if (!calc_flag.components || !calc_flag.events_3d) throw;
	
	duration &= !calc_flag.duration;
	max_projection &= !calc_flag.max_projection;
	if (!duration && !max_projection)
	{
		astro_log.set_info(L"~Calculating events information.");
		return components;
	}	
	
	components.resize(all_events_3d.size());
	for (int i = 0; i < (int)components.size(); i++)
	{
		components[i].key = -1;
	}
	boost::dynamic_bitset<> projection(current->nm);
	int idx = 0;
	for (auto v : all_events_3d) 
	{
		auto & cur = components[idx++];
		if (v.second.size()) cur.key = v.first;
		if (duration)
		{
			cur.start = v.second.front().t;
			cur.finish = v.second.back().t;
		}
		if (max_projection)
		{
			projection.reset();
			for (auto pt : v.second)
			{
				projection.set(pt.x * current->m + pt.y);
			}
			cur.max_projection = (int)projection.count();
		}
	}
	calc_flag.duration |= duration;
	calc_flag.max_projection |= max_projection;	
	astro_log.set_info(L"~Calculating events information.");
	return components;
}

void astrocyte::filter_events()
{
	astro_log.set_info(L"Filtering short and small events.");
	if (segm.min_area > 0 || segm.min_duration > 0)
	{
		for (int i = 0; i < components.size(); i++)
		{
			auto & x = components[i];
			if (x.len() >= segm.min_duration && x.max_projection >= segm.min_area)
			{
				x.good = true;
				selected_components.push_back(x);
				selected_events_3d[x.key] = all_events_3d[x.key];
			}
			else
			{
				x.good = false;
			}
		}
	}
#ifdef DUMP_DATA
	Utilities::save_events_3d(selected_events_3d, DUMP_PATH);
	Utilities::save_events_info(selected_components, DUMP_PATH);
#endif
	astro_log.set_info(L"~Filtering short and small events.");
}

unordered_map<int, vector <video_point>> astrocyte::get_3d_events()
{
	if (!calc_flag.components) throw;
	if (calc_flag.events_3d) 
	{
		return all_events_3d;
	}
	astro_log.set_info (L"Get video of events");
	std::memset(pos, 0, current->nm * sizeof ushort);
	for (ushort t = 0; t < current->nt; t++)
	{
		for (int i = 0; i < current->n - segm.a + 1; i++)
		{
			for (int j = 0; j < current->m - segm.a + 1; j++)
			{
				int ind = i * current->m + j;
				if (pos[ind] < graph[ind].size() &&
					graph[ind][pos[ind]].finish < t)
				{
					pos[ind]++;
				}
				
				if (pos[ind] >= graph[ind].size() || 
					graph[ind][pos[ind]].start > t) continue;
				
				int cur = graph[ind][pos[ind]].key;
				if (mask[t * current->nm + i * current->m + j])
				{
					all_events_3d[cur].push_back({ ushort(i), ushort(j), t });
				}
			}
		}
	}
	calc_flag.events_3d = true;
#ifdef DUMP_DATA
	Utilities::save_events_3d(all_events_3d, DUMP_PATH);
#endif
	astro_log.set_info (L"~Get video of events");
	return all_events_3d;
}

void astrocyte::build_events(const video_data & df_f0_video)
{
	current = &df_f0_video;

	boost::dynamic_bitset<> * mask_p = 
		new boost::dynamic_bitset<> [current->nm];
	for (int i = 0; i < current->nm; i++)
	{
		mask_p[i].resize(current->nt);
	}
	mask.resize(current->size); // true if (i, j, t) is active
	active_mask(mask_p);

	if (graph)
	{
		delete[] graph;
	}
	graph = new vector<vertex>[current->nm];
	int num_vertex = clustering_intervals(mask_p);
	delete[]mask_p;

	if (pos)
	{
		delete[]pos;
	}
	pos = new ushort[current->nm];
	union_clusters(num_vertex);	
}
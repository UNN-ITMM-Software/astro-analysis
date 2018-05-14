#include <gtest.h>
#include <stdio.h>
#include "astrocyte.h"
#include "utilities.h"

function <void(const logger & lg)> create_log_update()
{
	auto log_update = [](const logger & lg) {
		if (lg.get_history().empty()) return;
		const auto & last = lg.get_history().back();
		
		std::string message = std::wstring_convert<
			std::codecvt_utf8<wchar_t >> ().to_bytes(last.message);
		
		printf("%s\n", message.c_str());
	};
	return log_update;
}

class astrocyte_test : public astrocyte
{
public:
	astrocyte_test(function <void(const logger & lg)> log_update = {}) :
		astrocyte(log_update) { };
	using astrocyte::active_mask;
	using astrocyte::clustering_intervals;
	using astrocyte::union_clusters;
	using astrocyte::find_activity_moments;
	using astrocyte::create_graph_vertex;
	using astrocyte::mask;
	using astrocyte::find_active_points;
	using astrocyte::union_frame_points;
	using astrocyte::set_component_idx;

	using astrocyte::graph;
	using astrocyte::pos;
};

class astrocyte_test_factory
{
public:
	static astrocyte_test *create_astrocyte()
	{
		const int n = 3, m = 3, nt = 40;
		auto log_update = create_log_update();
		auto astro = new astrocyte_test(log_update);
		video_data *current = new video_data();
		float *data = new float[n * m * nt];
		current->reset((uchar*)data, n, m, nt, CV_32FC1);
		astro->current = current;
		astro->pos = new ushort[n * m];
		astro->graph = new vector<vertex>[n * m];
		astro->segm.a = 1;

		astro->graph[0].push_back({ 0, 0, 12 });
		astro->graph[0].push_back({ 1, 19, 25 });
		astro->graph[0].push_back({ 2, 30, 38 });

		astro->graph[1].push_back({ 3, 0, 10 });
		astro->graph[1].push_back({ 4, 30, 38 });

		astro->graph[2].push_back({ 5, 0, 11 });
		astro->graph[2].push_back({ 6, 19, 25 });
		astro->graph[2].push_back({ 7, 30, 38 });

		astro->graph[3].push_back({ 8, 17, 25 });
		astro->graph[3].push_back({ 9, 31, 38 });

		astro->graph[4].push_back({ 10, 3, 12 });
		astro->graph[4].push_back({ 11, 19, 25 });
		astro->graph[4].push_back({ 12, 32, 35 });
		astro->graph[4].push_back({ 13, 37, 39 });

		astro->graph[5].push_back({ 14, 0, 12 });
		astro->graph[5].push_back({ 15, 19, 25 });

		astro->graph[6].push_back({ 16, 2, 15 });
		astro->graph[6].push_back({ 17, 20, 27 });

		astro->graph[7].push_back({ 18, 2, 27 });

		astro->graph[8].push_back({ 19, 2, 10 });
		astro->graph[8].push_back({ 20, 22, 25 });
		astro->graph[8].push_back({ 21, 29, 34 });
		astro->graph[8].push_back({ 22, 36, 39 });

		std::memset(astro->pos, 0, n * m * sizeof(ushort));
		return astro;
	}
};

TEST(astrocyte_test, can_create_astrocyte)
{
	auto log_update = create_log_update();
	ASSERT_NO_THROW(new astrocyte(log_update));
}

TEST(DISABLED_astrocyte_test, check_normalization_of_source_video)
{
	const int n = 5, m = 5, nt = 4;
	const uchar min_value = 20, max_value = 190,
		lb = 50, rb = 255;

	auto log_update = create_log_update();
	auto astro = new astrocyte(log_update);
	
	video_data source_video, preprocessed_video;	
	uchar *data = new uchar[n * m * nt];
	for (int i = 0; i < n * m * nt; i+= 2)
	{
		data[i] = min_value;
	}
	for (int i = 1; i < n * m * nt; i += 2)
	{
		data[i] = max_value;
	}
	source_video.reset(data, n, m, nt, CV_8UC1);
	astro->normalization(source_video, preprocessed_video, lb, rb);
	EXPECT_EQ(preprocessed_video.cell<uchar>(0, 0, 0), lb);
	EXPECT_EQ(preprocessed_video.cell<uchar>(0, 0, 1), rb);
}

TEST(DISABLED_astrocyte_test, check_smoothing_of_source_video)
{
	const int n = 4, m = 4, nt = 6;
	uchar values[nt] = { 1, 2, 3, 4, 5, 6 };
	int expected_values[nt] = { 1, 2, 3, 4, 5, 6 };

	auto log_update = create_log_update();
	auto astro = new astrocyte(log_update);

	video_data preprocessed_video;
	uchar *data = new uchar[n * m * nt];
	for (int i = 0; i < n; i++)
	{
		for (int j = 0; j < m; j++)
		{
			for (int k = 0; k < nt; k++)
			{
				data[k * n * m + i * m + j] = values[k];
			}
		}
	}
	preprocessed_video.reset(data, n, m, nt, CV_8UC1);
	astro->smoothing(preprocessed_video);
	for (int k = 0; k < nt; k++)
	{
		cv::Mat frame = preprocessed_video.image(k), converted_frame;
		frame.convertTo(converted_frame, CV_32SC1);
		cv::Mat expected_frame(frame.rows, frame.cols, 
			CV_32SC1, cv::Scalar(expected_values[k]));
		cv::Mat diff;
		cv::compare(converted_frame, expected_frame, diff, cv::CMP_NE);
		int nz = cv::countNonZero(diff);
		ASSERT_TRUE(nz == 0);
	}
}

TEST(astrocyte_test, check_active_pixels_mask)
{
	auto log_update = create_log_update();
	auto astro = new astrocyte_test(log_update);
	
	const int n = 4, m = 4, nt = 6;
	video_data current;
	float *data = new float[n * m * nt];
	srand(10);
	for (int i = 0; i < n; i++)
	{
		for (int j = 0; j < m; j++)
		{
			for (int k = 0; k < nt; k++)
			{
				if (((double)rand()) / RAND_MAX >= 0.5)
				{
					data[n * m * k + i * m + j] = 1.0f;
				}
				else
				{
					data[n * m * k + i * m + j] = 0.0f;
				}
			}
		}
	}
	current.reset((uchar*)data, n, m, nt, CV_32FC1);
	astro->current = &current;
	astro->mask.resize(current.size);
	boost::dynamic_bitset<> *mask_p = new boost::dynamic_bitset<>[current.nm];
	for (int i = 0; i < current.nm; i++)
	{
		mask_p[i].resize(current.nt);
	}
	astro->active_mask(mask_p);
	for (int k = 0; k < nt; k++)
	{
		for (int i = 0; i < n; i++)
		{
			for (int j = 0; j < m; j++)
			{
				ASSERT_EQ((uchar)mask_p[i * m + j].test(k),
					data[n * m * k + i * m + j]);
			}
		}
	}
}

TEST(astrocyte_test, check_correctness_of_activity_moments)
{
	auto log_update = create_log_update();
	auto astro = new astrocyte_test(log_update);
	astro->segm.a = 3;
	const int n = 3, m = 3, nt = 20;
	boost::dynamic_bitset<> *mask_p = new boost::dynamic_bitset<>[n * m];
	for (int i = 0; i < n * m; i++)
	{
		mask_p[i].resize(nt);
	}
	srand(10);
	for (int i = 0; i < n; i++)
	{
		for (int j = 0; j < m; j++)
		{
			for (int k = 0; k < nt; k++)
			{
				if (((double)rand()) / RAND_MAX >= 0.9)
				{
					mask_p[i * m + j].set(k);
				}		
			}
		}
	}
	vector<ushort> active; 
	video_data current;
	uchar *data = new uchar[n * m * nt];
	current.reset(data, n, m, nt, CV_8UC1);
	astro->current = &current;
	astro->find_activity_moments(mask_p, 0, 0, active);
	
	vector<ushort> expected_active;
	expected_active.push_back(0); expected_active.push_back(1);
	expected_active.push_back(3); expected_active.push_back(5);
	expected_active.push_back(6); expected_active.push_back(7);
	expected_active.push_back(8); expected_active.push_back(10);
	expected_active.push_back(13); expected_active.push_back(14);
	expected_active.push_back(17); expected_active.push_back(19);
	
	ASSERT_EQ(expected_active, active);
}

TEST(astrocyte_test, check_searching_active_points_frame_0)
{
	const int frame_idx = 0;
	auto astro = astrocyte_test_factory::create_astrocyte();
	astro->find_active_points(frame_idx);
	ASSERT_EQ(0, astro->pos[0]); ASSERT_EQ(0, astro->pos[1]);
	ASSERT_EQ(0, astro->pos[2]); ASSERT_EQ(0, astro->pos[3]);
	ASSERT_EQ(0, astro->pos[4]); ASSERT_EQ(0, astro->pos[5]);
	ASSERT_EQ(0, astro->pos[6]); ASSERT_EQ(0, astro->pos[7]);
	ASSERT_EQ(0, astro->pos[8]);
}

TEST(astrocyte_test, check_searching_active_points_frame_4)
{
	const int frame_idx = 4;
	auto astro = astrocyte_test_factory::create_astrocyte();
	for (int i = 0; i <= frame_idx; i++)
	{
		astro->find_active_points(i);
	}
	ASSERT_EQ(0, astro->pos[0]); ASSERT_EQ(0, astro->pos[1]);
	ASSERT_EQ(0, astro->pos[2]); ASSERT_EQ(0, astro->pos[3]);
	ASSERT_EQ(0, astro->pos[4]); ASSERT_EQ(0, astro->pos[5]);
	ASSERT_EQ(0, astro->pos[6]); ASSERT_EQ(0, astro->pos[7]);
	ASSERT_EQ(0, astro->pos[8]);
}

TEST(astrocyte_test, check_searching_active_points_frame_14)
{
	const int frame_idx = 14;
	auto astro = astrocyte_test_factory::create_astrocyte();
	for (int i = 0; i <= frame_idx; i++)
	{
		astro->find_active_points(i);
	}
	ASSERT_EQ(1, astro->pos[0]); ASSERT_EQ(1, astro->pos[1]);
	ASSERT_EQ(1, astro->pos[2]); ASSERT_EQ(0, astro->pos[3]);
	ASSERT_EQ(1, astro->pos[4]); ASSERT_EQ(1, astro->pos[5]);
	ASSERT_EQ(0, astro->pos[6]); ASSERT_EQ(0, astro->pos[7]);
	ASSERT_EQ(1, astro->pos[8]);
}

TEST(astrocyte_test, check_searching_active_points_frame_30)
{
	const int frame_idx = 33;
	auto astro = astrocyte_test_factory::create_astrocyte();
	for (int i = 0; i <= frame_idx; i++)
	{
		astro->find_active_points(i);
	}
	ASSERT_EQ(2, astro->pos[0]); ASSERT_EQ(1, astro->pos[1]);
	ASSERT_EQ(2, astro->pos[2]); ASSERT_EQ(1, astro->pos[3]);
	ASSERT_EQ(2, astro->pos[4]); ASSERT_EQ(2, astro->pos[5]);
	ASSERT_EQ(2, astro->pos[6]); ASSERT_EQ(1, astro->pos[7]);
	ASSERT_EQ(2, astro->pos[8]);
}

TEST(astrocyte_test, check_searching_active_points_frame_33)
{
	const int frame_idx = 33;
	auto astro = astrocyte_test_factory::create_astrocyte();
	for (int i = 0; i <= frame_idx; i++)
	{
		astro->find_active_points(i);
	}
	ASSERT_EQ(2, astro->pos[0]); ASSERT_EQ(1, astro->pos[1]);
	ASSERT_EQ(2, astro->pos[2]); ASSERT_EQ(1, astro->pos[3]);
	ASSERT_EQ(2, astro->pos[4]); ASSERT_EQ(2, astro->pos[5]);
	ASSERT_EQ(2, astro->pos[6]); ASSERT_EQ(1, astro->pos[7]);
	ASSERT_EQ(2, astro->pos[8]);
}

TEST(astrocyte_test, check_union_frame_0_points)
{
	const int frame_idx = 0;
	auto astro = astrocyte_test_factory::create_astrocyte();
	astro->segm.a = 2;
	astro->segm.thr_area = 0.5;
	astro->segm.thr_time = 0.5;
	int num_verteces = 23;

	int *rank = new int[num_verteces], *parent = new int[num_verteces];
	boost::disjoint_sets<int *, int *> ds =
		boost::disjoint_sets<int *, int *>(rank, parent);
	for (int i = 0; i < num_verteces; i++)
	{
		ds.make_set(i);
	}

	astro->find_active_points(frame_idx);
	astro->union_frame_points(ds, frame_idx);
	ASSERT_EQ(ds.find_set(0), ds.find_set(3));
}

TEST(astrocyte_test, check_union_frame_3_points)
{
	const int frame_idx = 19;
	auto astro = astrocyte_test_factory::create_astrocyte();
	astro->segm.a = 2;
	astro->segm.thr_area = 0.5;
	astro->segm.thr_time = 0.5;
	int num_verteces = 23;

	int *rank = new int[num_verteces], *parent = new int[num_verteces];
	boost::disjoint_sets<int *, int *> ds =
		boost::disjoint_sets<int *, int *>(rank, parent);
	for (int i = 0; i < num_verteces; i++)
	{
		ds.make_set(i);
	}

	for (int i = 0; i <= frame_idx; i++)
	{
		astro->find_active_points(i);
		astro->union_frame_points(ds, i);
	}	
	ASSERT_EQ(ds.find_set(1), ds.find_set(8));
}

TEST(astrocyte_test, check_searching_active_points_frame_30_a_2)
{
	const int frame_idx = 30;
	auto astro = astrocyte_test_factory::create_astrocyte();
	astro->segm.a = 2;
	
	for (int i = 0; i <= frame_idx; i++)
	{
		astro->find_active_points(i);
	}

	ASSERT_EQ(2, astro->pos[0]); ASSERT_EQ(1, astro->pos[1]);
	ASSERT_EQ(0, astro->pos[2]); ASSERT_EQ(1, astro->pos[3]);
	ASSERT_EQ(2, astro->pos[4]); ASSERT_EQ(0, astro->pos[5]);
	ASSERT_EQ(0, astro->pos[6]); ASSERT_EQ(0, astro->pos[7]);
	ASSERT_EQ(0, astro->pos[8]);
}

TEST(astrocyte_test, check_union_points_frame_38_a_2)
{
	const int frame_idx = 38;
	auto astro = astrocyte_test_factory::create_astrocyte();
	astro->segm.a = 2;
	astro->segm.thr_area = 0.5;
	astro->segm.thr_time = 0.5;
	int num_verteces = 23;

	int *rank = new int[num_verteces], *parent = new int[num_verteces];
	boost::disjoint_sets<int *, int *> ds =
		boost::disjoint_sets<int *, int *>(rank, parent);
	for (int i = 0; i < num_verteces; i++)
	{
		ds.make_set(i);
	}

	for (int i = 0; i <= frame_idx; i++)
	{
		astro->find_active_points(i);
		astro->union_frame_points(ds, i);
	}

	ASSERT_EQ(ds.find_set(0), ds.find_set(3));

	ASSERT_EQ(ds.find_set(1), ds.find_set(8));
	ASSERT_EQ(ds.find_set(1), ds.find_set(11));

	ASSERT_EQ(ds.find_set(2), ds.find_set(4));
	ASSERT_EQ(ds.find_set(2), ds.find_set(9));
}

TEST(astrocyte_test, check_set_component_indeces)
{
	const int frame_idx = 38;
	auto astro = astrocyte_test_factory::create_astrocyte();
	astro->segm.a = 2;
	astro->segm.thr_area = 0.5;
	astro->segm.thr_time = 0.5;
	int num_verteces = 23;

	int *rank = new int[num_verteces], *parent = new int[num_verteces];
	boost::disjoint_sets<int *, int *> ds =
		boost::disjoint_sets<int *, int *>(rank, parent);
	for (int i = 0; i < num_verteces; i++)
	{
		ds.make_set(i);
	}

	for (int i = 0; i <= frame_idx; i++)
	{
		astro->find_active_points(i);
		astro->union_frame_points(ds, i);
	}
	for (int i = 0; i < num_verteces - 1; i++)
	{
		cout << "[" << i << ", " << ds.find_set(i) << "]; ";
	}
	cout << "[" << num_verteces - 1 << ", " << 
		ds.find_set(num_verteces - 1) << "]" << endl;
	int cnt = astro->set_component_idx(ds, num_verteces);	
	EXPECT_EQ(cnt, 15);

	EXPECT_EQ(ds.find_set(0), ds.find_set(3));
	EXPECT_EQ(ds.find_set(0), ds.find_set(10));

	EXPECT_EQ(ds.find_set(1), ds.find_set(8));
	EXPECT_EQ(ds.find_set(1), ds.find_set(11));

	EXPECT_EQ(ds.find_set(2), ds.find_set(4));
	EXPECT_EQ(ds.find_set(2), ds.find_set(9));
	EXPECT_EQ(ds.find_set(2), ds.find_set(12));
	EXPECT_EQ(ds.find_set(2), ds.find_set(13));
}

TEST(astrocyte_test, check_get_3d_events_a_2)
{
	const int frame_idx = 38;
	auto astro = astrocyte_test_factory::create_astrocyte();
	astro->segm.a = 2;
	astro->segm.thr_area = 0.5;
	astro->segm.thr_time = 0.5;
	int num_verteces = 23;

	astro->mask.resize(astro->current->size);
	for (int i = 0; i < astro->current->size; i++)
		astro->mask[i] = true;
	astro->union_clusters(num_verteces);

	unordered_map<int, vector <video_point>> events_3d =
		astro->get_3d_events();
	///*
	for (auto e : events_3d)
	{
		cout << "Event " << e.first << ": ";
		for (int i = 0; i < e.second.size() - 1; i++)
		{
			cout << "(" << e.second[i].x << ", " <<
				e.second[i].y << ", " <<
				e.second[i].t << "), ";
		}
		cout << "(" << e.second[e.second.size() - 1].x << ", " <<
			e.second[e.second.size() - 1].y << ", " <<
			e.second[e.second.size() - 1].t << ")" << endl;
	}
	// */
	ASSERT_EQ(events_3d.size(), 3);
}

TEST(astrocyte_test, check_events_info_without_filtering)
{
	auto astro = astrocyte_test_factory::create_astrocyte();
	astro->segm.a = 2;
	astro->segm.thr_area = 0.5;
	astro->segm.thr_time = 0.5;
	astro->segm.min_duration = 5;
	astro->segm.min_area = 0;
	int num_verteces = 23, num_components;

	astro->mask.resize(astro->current->size);
	for (int i = 0; i < astro->current->size; i++)
		astro->mask[i] = true;
	num_components = astro->union_clusters(num_verteces);
	unordered_map<int, vector <video_point>> events_3d =
		astro->get_3d_events();
	vector<component> comps = astro->get_events_info();
	
	ASSERT_EQ(comps.size(), 3);
	ASSERT_EQ(comps[0].max_projection, 3);
	ASSERT_EQ(comps[1].max_projection, 3);
	ASSERT_EQ(comps[2].max_projection, 4);
}

TEST(astrocyte_test, check_events_info_with_filtering)
{
	auto astro = astrocyte_test_factory::create_astrocyte();
	astro->segm.a = 2;
	astro->segm.thr_area = 0.5;
	astro->segm.thr_time = 0.5;
	astro->segm.min_duration = 5;
	astro->segm.min_area = 4;
	int num_verteces = 23, num_components;

	astro->mask.resize(astro->current->size);
	for (int i = 0; i < astro->current->size; i++)
		astro->mask[i] = true;
	num_components = astro->union_clusters(num_verteces);
	astro->get_3d_events();
	astro->get_events_info();
	astro->filter_events();
	auto & comps = astro->selected_components;

	ASSERT_EQ(comps.size(), 1);
	ASSERT_EQ(comps[0].max_projection, 4);
}

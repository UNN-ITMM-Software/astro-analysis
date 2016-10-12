#ifndef UTILITIES_H
#define UTILITIES_H

#include <boost/dynamic_bitset.hpp>
#include <unordered_map>
#include "component.h"
#include "video_data.h"

class Utilities
{
private:
	static int idx;
public:
	static std::string get_full_file_name(const char *path, const char *name);

	static void save_activity_mask(const char *file_name,
		boost::dynamic_bitset<> * &mask_p,
		const int n, const int m, const int nt);

	static void load_activity_mask(const char *file_name,
		boost::dynamic_bitset<> * &mask_p);

	static void get_sub_matrix(const boost::dynamic_bitset<> * mask_p,
		const int n, const int m, const int nt,
		const int x, const int y, const int ns, const int ms, const int nts,
		boost::dynamic_bitset<> * &sub_mask);

	static void save_graph_verteces(vector<vertex> *graph, 
		int n ,int m, const char *file_name);

	static void save_events_info(std::vector<component> &comps, 
		const char *file_name);

	static void save_events_3d(
		unordered_map<int, vector <video_point>> &events, const char *path);
	
	static void save_square_mask(boost::dynamic_bitset<> &mask_square, 
		const char *path);
};

#endif

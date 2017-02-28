#ifndef ASTROCYTE_H
#define ASTROCYTE_H

#include "declaration.h"
#include "config.h"
#include "logger.h"
#include "geometry.h"
#include "video_data.h"
#include "vertex.h"
#include "component.h"
#include "segmentation_settings.h"
#include "auxiliaries.h"
#include "clusters.h"
#include "dbscan.h"

#include <boost/pending/disjoint_sets.hpp>
#include <boost/dynamic_bitset.hpp>
#include <set>
#include <unordered_map>
#include <unordered_set>

#include <uchar.h>
#include <mat.h>

class astrocyte
{
public:
    // processed video
    const video_data * current;
    // logger
    logger astro_log;

protected:
    // array (n*m) of vectors consisting of time intervals
    vector<vertex> * graph { nullptr };
    // mask (n*m*nt) of active pixels
    vector<bool> mask;
    // array (n*m) of indeces of time intervals
    ushort * pos { nullptr };    

public:
    segmentation_settings segm;
    struct calc_flag
    {
        bool components { false }, duration { false }, 
            max_projection { false }, events_3d { false };
        void set_false () { memset (this, false, sizeof (*this)); };
    } calc_flag;
        
    // vectors of 3d events
    unordered_map<int, vector <video_point>> all_events_3d, selected_events_3d;

    vector<component> components, selected_components;

    astrocyte(function <void (const logger & lg)> log_update = {});
    void settings(segmentation_settings sett) { segm = sett; };
    ~astrocyte();

public:
    // 1. Preprocess frames
    void normalization(const video_data & source_video,
        video_data & preprocessed_video, 
        const uchar lb = 0, const uchar rb = 255);
    void smoothing(video_data & preprocessed_video, 
        const int l = 1, const int r = 1);
    void preprocessing(const video_data & source_video, 
        video_data & preprocessed_video,
        const uchar lb = 0, const uchar rb = 255,
        bool smooth_by_time = true);
    
    // 2. Compute df/f0 (background/foreground classification)
    void background_subtraction(const video_data & source_video, 
        video_data & df_f0_video, video_data & background_video, 
        int thr_df_f0 = THR_DF_F0);

    // 3. Construct events
    // 3.1. Construct graph + search connectivity components
    void build_events(const video_data & df_f0_video);
    // 3.2. Convert connectivity components to the set of points
    unordered_map<int, vector <video_point>> get_3d_events();
    // 3.3. Extract events information
    vector<component> get_events_info(bool duration = true,
        bool max_projection = true);
    // 3.4. Remove short and small events
    void filter_events();

protected:
    // Auxiliary methods used in 3.1
    void active_mask(boost::dynamic_bitset<> * mask_p);
    void find_activity_moments(boost::dynamic_bitset<> * &mask_p, 
        int i, int j, std::vector<ushort> &active);
    void find_activity_moments(boost::dynamic_bitset<> * &mask_p,
        int i, int j, Points &active);
    void create_graph_vertex(const vector<ushort> &clusters, 
        const std::vector<ushort> &active, int num, vector<vertex> &res);
    void create_graph_vertex(const vector<ClusterId> &clusterIds,
        const Points &ps, int num, vector<vertex> &res);
    int clustering_intervals(boost::dynamic_bitset<> * &mask_p);
    
    void find_active_points(int frame_idx);
    void union_frame_points(boost::disjoint_sets<int *, int *> &ds, 
        int frame_idx);
    int set_component_idx(boost::disjoint_sets<int *, int *> &ds, int num);
    int union_clusters(int num);    
};

#endif
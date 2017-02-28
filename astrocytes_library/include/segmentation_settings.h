#ifndef SEGM_SETTINGS_H
#define SEGM_SETTINGS_H

#include "config.h"

struct segmentation_settings
{
    enum soma 
    { 
        SOMA, 
        NOT_SOMA, 
        ALL 
    } flag_soma { ALL };

    int cnt = 7;
    
    // parameters correspond to config.h
    int thr_df_f0 = 5;
    int a, min_points, eps;
    double thr_area, thr_time;    
    int min_area{ MIN_AREA }, min_duration{ MIN_DURATION };    
    
    segmentation_settings() : a(LENGTH_A), min_points(MIN_POINTS), eps(EPS),
        thr_area(THR_AREA), thr_time(THR_TIME), thr_df_f0(THR_DF_F0) {};

    segmentation_settings(int a_, int min_points_, int eps_, double thr_area_,
        double thr_time_) : a(a_), min_points(min_points_), eps(eps_),
        thr_area(thr_area_), thr_time(thr_time_) {};
};

#endif

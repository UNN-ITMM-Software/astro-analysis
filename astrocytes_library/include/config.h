#ifndef CONFIG_H
#define CONFIG_H

// Default configuration parameters

#define FILE_NAME "2013-05-22_fileNo03_z-max_bm3d.mat"

#define DUMP_DATA
#define DUMP_PATH "./dump_data/"

// side of sliding window
#define LENGTH_A 10
// munimum number of points in one cluster
#define MIN_POINTS 5
// neighbourhood points in cluster
#define EPS 6
// threshold of overlapping area in the range [0, 1]
#define THR_AREA 0.5
// threshold of overlapping time intervals in the range [0, 1]
#define THR_TIME 0.5
// left bound for normalization
#define LEFT_BOUND 55
// left bound for normalization
#define RIGHT_BOUND 255
// threshold for background/foreground classification
#define THR_DF_F0 10
// minimum event area
#define MIN_AREA 10
// minimum event duration
#define MIN_DURATION 5

#endif
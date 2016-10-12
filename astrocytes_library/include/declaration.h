#ifndef DECLARATION_H
#define DECLARATION_H

#include <boost/filesystem/operations.hpp>
#include <boost/filesystem/path.hpp>
#include <boost/filesystem/fstream.hpp> 

#include <string>
#include <codecvt>
#include <ctime>
#include <iostream>

#include <opencv2/opencv.hpp> 

using namespace std;
using namespace cv;
namespace fs = boost::filesystem;

template <typename T> inline T sqr (T x) { return x * x; }

#endif
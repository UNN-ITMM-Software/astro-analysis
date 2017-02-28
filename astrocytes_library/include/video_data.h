#ifndef VIDEO_DATA
#define VIDEO_DATA

#include "declaration.h"

const int sizeof_opencv[7] = { 1, 1, 2, 2, 4, 4, 8 };

//CV_8U   0
//CV_8S   1
//CV_16U  2
//CV_16S  3
//CV_32S  4
//CV_32F  5
//CV_64F  6

struct video_point
{
    ushort x, y, t;
};

class video_data
{
private:
    uchar * data{ nullptr };
    bool del{ true };
public:
    int n, m, nt, img_type, type_size;
    size_t nm, size;
    video_data() : data(nullptr), n(0), m(0), nt(0), img_type(0),
        type_size(0), nm(0), size(0)
    {};
    video_data(uchar * data_, int n_, int m_, int nt_, int img_type_,
        bool del_ = true) : data(data_), n(n_), m(m_), nt(nt_), nm(n * m),
        size(nm * nt), img_type(img_type_), type_size(sizeof_opencv[img_type]),
        del(del_)
    {};
    ~video_data() { if (del && data) delete[] data; }
    void clear() { if (del && data) delete[] data; };
    void reset(uchar * data_, int n_, int m_, int nt_, int img_type_,
        bool del_ = true)
    {
        clear();
        data = data_, n = n_, m = m_, nt = nt_, nm = (size_t)n * m,
            size = (size_t)nm * nt, img_type = img_type_,
            type_size = sizeof_opencv[img_type], del = del_;
    }
    uchar * frame(int t) const { return data + nm * t * type_size; };
    Mat image(int t) const { return Mat(n, m, img_type, frame(t)); };
    uchar * get_data() { return data; };
    uchar cell(int t, int i, int j) const { return data[t * nm + i * m + j]; }
    void cell(int t, int i, int j, int val) { data[t * nm + i * m + j] = val; }

    void set_nt(int nt) { this->nt = nt; this->size = nm * nt; }
};

#endif

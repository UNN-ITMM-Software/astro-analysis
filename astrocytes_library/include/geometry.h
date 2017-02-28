#ifndef GEOMETRY_H
#define GEOMETRY_H

struct real_rectangle
{
    double x, y, width, height;
    real_rectangle () : x (0.0), y (0.0), width (0.0), height (0.0)
    {}

    real_rectangle (double x, double y, double width, double height) : 
        x (x), y (y), width (width), height (height)
    {}
};

struct real_point
{
    double x, y;
};

#endif

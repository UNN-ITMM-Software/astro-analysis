#ifndef DISTANCE_H
#define DISTANCE_H
#include <boost/numeric/ublas/vector.hpp>

// Euclidean distance
template 
<typename VEC_T>	
class Euclidean {
	
protected:                  

	typedef typename VEC_T vector_type;

	// this must be not directly accessible 
	// since we want to provide a rich set of distances	

	double getDistance(const VEC_T v1, const VEC_T v2)
	{
		return norm_2(v1-v2);
	};
	double getSimilarity(const VEC_T v1, const VEC_T v2)
	{
		return 1.0 / getDistance(v1, v2);
	};
};
	
template
<typename Distance_Policy>   // this allows to provide a static mechanism for pseudo-like 
								// inheritance, which is optimal from a performance point of view.
class Distance : Distance_Policy
{
	using Distance_Policy::getDistance;

public:
	double distance(typename Distance_Policy::vector_type x, 
		typename Distance_Policy::vector_type y)
	{
		return getDistance(x, y);
	};

	double similarity(typename Distance_Policy::vector_type x, 
		typename Distance_Policy::vector_type y)
	{
		return getSimilarity(x, y);
	};

	};

#endif
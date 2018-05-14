/*
function [] = calc_integrated_information(FRx, FRXy, Mx, Mxy, Nx, Nxy)
*/

#include <mex.h>
#include <matrix.h>
#include "compute_ii.h"

using namespace std;

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	int Nx, Nxy;
	counttype Mx, Mxy;
	counttype * FRx, * FRxy;
	
	FRx = (counttype *)mxGetData(prhs[0]);
	FRxy = (counttype *)mxGetData(prhs[1]);
	Mx = mxGetScalar(prhs[2]);
	Mxy = mxGetScalar(prhs[3]);
	Nx = mxGetScalar(prhs[4]);
	Nxy = mxGetScalar(prhs[5]);
	
	basetype MIB;
	double integral_information = compute_ii(FRx, FRxy, Mx, Mxy, MIB, Nx, Nxy);

	plhs[0] = mxCreateDoubleScalar(integral_information);
}
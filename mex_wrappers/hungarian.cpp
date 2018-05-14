/*
function [assignment, cost] = hungarian(distMatrix)
*/

#include <mex.h>
#include <matrix.h>
#include <vector>
#include <algorithm>

using namespace std;

void hungarian(double * assignment, double * w, int n, int m);

void mexFunction( int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[] )
{
	double * assignment, * dist_matrix;
	
	// Input arguments 
	// Assume m < n
	int m = mxGetM(prhs[0]);
	int n = mxGetN(prhs[0]);
	dist_matrix = mxGetPr(prhs[0]);
	
	/* Output arguments */
	plhs[0]    = mxCreateDoubleMatrix(m, 1, mxREAL);
	assignment = mxGetPr(plhs[0]);
	
	/* Call C-function */
	hungarian(assignment, dist_matrix, m, n);	
}

void hungarian(double * assignment, double * w, int n, int m) 
{
	const double INF = 1e9;
	vector<double> u (n+1), v (m+1);
	vector <int> p (m+1), way (m+1);
	for (int i=1; i<=n; ++i) {
		p[0] = i;
		int j0 = 0;
		vector<double> minv (m+1, INF);
		vector<char> used (m+1, false);
		do {
			used[j0] = true;
			int i0 = p[j0], j1;
			double delta = INF;
			for (int j=1; j<=m; ++j)
				if (!used[j]) {
					int cur = w[(i0 - 1) + (j - 1) * n]-u[i0]-v[j];
					if (cur < minv[j])
						minv[j] = cur,  way[j] = j0;
					if (minv[j] < delta)
						delta = minv[j],  j1 = j;
				}
			for (int j=0; j<=m; ++j)
				if (used[j])
					u[p[j]] += delta,  v[j] -= delta;
				else
					minv[j] -= delta;
			j0 = j1;
		} while (p[j0] != 0);
		do {
			int j1 = way[j0];
			p[j0] = p[j1];
			j0 = j1;
		} while (j0);
	}
	vector<int> ans (n+1);
	for (int j=1; j<=m; ++j)
		ans[p[j]] = j;
	for (int j=1; j<=n; ++j)	
		assignment[j - 1] = ans[j];
}
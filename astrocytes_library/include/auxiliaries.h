#ifndef AUXILIARIES_H
#define AUXILIARIES_H

#include "declaration.h"

template<typename T, typename T2> 
void smooth(const vector <T, std::allocator<T>> & input,
	vector<T> & output, int l, int r)
{
	T2 m = 0;
	int a = r + l + 1, n = (int)input.size();
	for (int i = 0; i < a; i++)
	{
		m += input[i], output[i] = input[i],
			output[n - i - 1] = input[n - i - 1];
	}

	for (int i = a; i < n; i++)
	{
		output[i - r - 1] = T(m / a);
		m += input[i] - input[i - a];
	}
};

inline vector<ushort> dbscan(const vector<ushort> &a, int min_points, int eps) // dbscan3
{
	enum : char { UNDEFINED = 0, REACH = 1, CORE = 2 };
	int n = (int)a.size();
	vector <char> b(n);
	vector <ushort> c(n);

	for (int i = 0; i < n; i++) {
		int cnt = 1;
		int j = i - 1;
		while (j >= 0 && abs(a[i] - a[j]) < eps && cnt < min_points) j--, cnt++;
		j = i + 1;
		while (j < n && abs(a[i] - a[j]) < eps && cnt < min_points) j++, cnt++;
		if (cnt >= min_points) b[i] = CORE;
	}
	int id_cluster = 0;
	for (int i = 0; i < n; i++) {
		if (b[i] != CORE) continue;
		id_cluster++;
		int j = i - 1;
		while (j >= 0 && abs(a[i] - a[j]) < eps) { c[j] = id_cluster; j--; }
		c[i] = id_cluster;
		i++;
		while (b[i] == CORE && i < n && abs(a[i] - a[i - 1]) < eps) c[i] = id_cluster, i++;
		j = i - 1;
		while (j < n && abs(a[i] - a[j]) < eps) { c[j] = id_cluster; j++; }
	}

	for (int i = 0; i < n; i++) if (c[i] == 0) c[i] = ++id_cluster;
	return c;

}

/*{
	int n = (int)a.size();
	vector<pair <int, int>> b;
	vector<ushort> c;
	b.reserve(n);
	int l = 0, r = 0;
	for (int i = 0; i < n; i++)
	{
		while (l < i && a[i] - a[l] > eps) l++;
		while (r < n && a[r] - a[i] <= eps) r++;
		if (r - l >= min_points) b.push_back(make_pair(a[l], a[r - 1]));
		else b.push_back(make_pair(-1, -1));
	}
	r = b[0].second;
	ushort cur = 0;
	bool flag = b[0].first != -1;
	if (flag) c.push_back(cur);
	else c.push_back(65535);
	for (int i = 1; i < n; i++)
	{
		if (flag)
		{
			if (a[i] <= r)
			{
				r = max(b[i].second, r);
				c.push_back(cur);
			}
			else
			{
				r = b[i].second;
				if (b[i].first == -1) r = a[i], flag = false;
				c.push_back(65535);
			}
		}
		else
		{
			if (b[i].first != -1)
			{
				int k = i - 1;
				cur++;
				while (k >= 0 && c[k] == 65535 && a[k] >= b[i].first) c[k] = cur, k--;
				r = b[i].second;
				c.push_back(cur);
				flag = true;
			}
			else
			{
				c.push_back(65535);
			}
		}
	}
	for (int i = 0; i < n; i++)
	{
		if (c[i] == 65535) c[i] = ++cur;
	}
	return c;
};*/

#endif

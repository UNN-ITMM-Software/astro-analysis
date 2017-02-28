#include "utilities.h"

int Utilities::idx = 0;

std::string Utilities::get_full_file_name(const char *path, const char *name)
{
    std::string full_name;
    full_name.append(path);
    full_name.append(name);
    full_name.append("_");
    full_name.append(std::to_string(idx));
    full_name.append(".csv");
    return full_name;
}

void Utilities::save_activity_mask(const char *path,
    boost::dynamic_bitset<> * &mask_p,
    const int n, const int m, const int nt)
{ 
    std::string file_name = get_full_file_name(path, "activity_mask");
    FILE *f = fopen(file_name.c_str(), "w");
    if (f == 0)
    {
        return;
    }
    fprintf(f, "%d;%d;%d\n", n, m, nt);
    for (int i = 0; i < n; i++)
    {
        for (int j = 0; j < m; j++)
        {
            fprintf(f, "%d;%d;;", i, j);
            for (int t = 0; t < nt - 1; t++)
            {
                fprintf(f, "%d;", mask_p[i * m + j].test(t));
            }
            fprintf(f, "%d\n", mask_p[i * m + j].test(nt - 1));
        }
        fprintf(f, "\n\n");
    }
    fclose(f);
}

void Utilities::load_activity_mask(const char *file_name,
    boost::dynamic_bitset<> * &mask_p)
{
    FILE *f = fopen(file_name, "r");
    if (f == 0)
    {
        return;
    }
    int n, m, nt;
    fscanf(f, "%d;%d;%d\n", &n, &m, &nt);
    mask_p = new boost::dynamic_bitset<>[n * m];
    for (int i = 0; i < n * m; i++)
    {
        mask_p[i].resize(nt);
    }
    for (int t = 0; t < nt; t++)
    {
        for (int i = 0; i < n; i++)
        {
            for (int j = 0; j < m; j++)
            {
                int val = 0;
                fscanf(f, "%d;", &val);
                if (val) mask_p[i * m + j].set(t);
            }
            fscanf(f, "\n");
        }
        fscanf(f, "\n\n");
    }
    fclose(f);
}

void Utilities::get_sub_matrix(const boost::dynamic_bitset<> * mask_p,
    const int n, const int m, const int nt,
    const int x, const int y, const int ns, const int ms, const int nts,
    boost::dynamic_bitset<> * &sub_mask)
{
    for (int t = 0; t < nts; t++)
    {
        for (int i = x; i < x + ns; i++)
        {
            for (int j = y; j < y + ms; j++)
            {
                if (mask_p[i * m + j].test(t)) 
                    sub_mask[(i - x) * ms + (j - y)].set(t);
            }
        }
    }
}

void Utilities::save_events_info(std::vector<component> &comps, 
    const char *path)
{
    std::string file_name = get_full_file_name(path, "events_info");
    FILE *f = fopen(file_name.c_str(), "w");
    if (f == 0)
    {
        return;
    }
    fprintf(f, "%d\n", comps.size());
    fprintf(f, "id;start;finish;duration;max_projection\n");
    for (int i = 0; i < comps.size(); i++)
    {
        fprintf(f, "%d;%d;%d;%d;%d\n", comps[i].key, comps[i].start, 
            comps[i].finish, comps[i].len(), comps[i].max_projection);
    }
    fclose(f);
}

void Utilities::save_graph_verteces(vector<vertex> *graph,
    int n, int m, const char *path)
{
    std::string file_name = get_full_file_name(path, "graph_verteces");
    FILE *f = fopen(file_name.c_str(), "w");
    if (f == 0)
    {
        return;
    }
    fprintf(f, "%d;%d\n", n, m);
    for (int i = 0; i < n; i++)
    {
        for (int j = 0; j < m; j++)
        {
            if (graph[i * m + j].size() == 0)
            {
                //fprintf(f, "%d;%d\n", i, j);
                continue;
            }
            fprintf(f, "%d;%d;;", i, j);
            for (int k = 0; k < graph[i * m + j].size() - 1; k++)
            {
                fprintf(f, "%d;%d;%d;;", graph[i * m + j][k].key,
                    graph[i * m + j][k].start, graph[i * m + j][k].finish);
            }
            fprintf(f, "%d;%d;%d\n", 
                graph[i * m + j][graph[i * m + j].size() - 1].key,
                graph[i * m + j][graph[i * m + j].size() - 1].start, 
                graph[i * m + j][graph[i * m + j].size() - 1].finish);
        }
    }
    fclose(f);
    idx++;
}

void Utilities::save_events_3d(unordered_map<int, vector <video_point>> &events,
    const char *path)
{
    std::string file_name = get_full_file_name(path, "events_3d");
    FILE *f = fopen(file_name.c_str(), "w");
    if (f == 0)
    {
        return;
    }
    fprintf(f, "%d\n", events.size());
    for (auto e : events)
    {
        fprintf(f, "%d:\n", e.first);
        for (int i = 0; i < e.second.size(); i++)
        {
            fprintf(f, "%d;%d;%d\n", e.second[i].t, e.second[i].x, e.second[i].y);
        }
        fprintf(f, "\n");
    }
    fclose(f);
    idx++;
}

void Utilities::save_square_mask(boost::dynamic_bitset<> &mask_square,
    const char *path)
{
    std::string file_name = get_full_file_name(path, "mask_square");
    FILE *f = fopen(file_name.c_str(), "w");
    if (f == 0)
    {
        return;
    }
    for (int i = 0; i < mask_square.size(); i++)
    {
        fprintf(f, "%d\n", mask_square.test(i));
    }
    fclose(f);
    idx++;
}
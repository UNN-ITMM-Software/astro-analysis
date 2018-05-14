#include <cstdio>
#include <uchar.h>
#include "mex.h"
#include "mat.h"
#include "astrocyte.h"

std::string help =
"First argument = df_f0 (matrix n x m x nt) of dF/F0 video.\n \
Last argument = params to algo (struct segmentation_settings)\n \
params = struct('a', " + to_string(LENGTH_A) + ", " +
"'min_points', " + to_string(MIN_POINTS) + ", " +
"'eps', " + to_string(EPS) + ", " +
"'thr_area', " + to_string(THR_AREA) + ", " +
"'thr_time', " + to_string(THR_TIME) + ", " +
"'min_area', " + to_string(MIN_AREA) + ", " +
"'min_duration', " + to_string(MIN_DURATION) + ");";

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	if (nrhs == 0)
    {
		mexErrMsgIdAndTxt ("MyToolbox:find_events:help", help.c_str());
	}
	
	std::string var_name = "";
    if (nrhs > 1 && mxIsChar(prhs[1]))
    {
        var_name = (char *)mxGetPr(prhs[1]);
    }
	auto log_update = [](const logger & lg)
    {
		if (lg.get_history().empty()) return;
        const auto & last = lg.get_history().back();
		
        std::string message = std::wstring_convert<
            std::codecvt_utf8<wchar_t>> ().to_bytes(last.message);

		mxArray * rhs = mxCreateString(message.c_str());
		mexCallMATLAB(0, nullptr, 1, &rhs, "add_info_log");
		mxDestroyArray(rhs);
	};
	
	astrocyte * astro = nullptr;
	segmentation_settings segm;
	if (mxIsStruct(prhs[nrhs - 1]))
    {
		const mxArray * param = prhs[nrhs - 1];
        int cnt = mxGetNumberOfFields(param);
		for (int i = 0; i < cnt; i++)
        {
            std::string name_field = mxGetFieldNameByNumber(param, i);
            mxArray * cur = mxGetFieldByNumber(param, 0, i);
			if (name_field == "a") {
                if (mxIsInt32(cur)) segm.a = *(int *)mxGetData(cur);
			} else if (name_field == "min_points") {
                if (mxIsInt32(cur)) segm.min_points = *(int *)mxGetData(cur);
			} else if (name_field == "eps") {
                if (mxIsInt32(cur)) segm.eps = *(int *)mxGetData(cur);
			} else if (name_field == "thr_area") {
                if (mxIsDouble(cur)) segm.thr_area = *(double *)mxGetData(cur);
			} else if (name_field == "thr_time") {
                if (mxIsDouble(cur)) segm.thr_time = *(double *)mxGetData(cur);
			} else if (name_field == "min_area") {
                if (mxIsInt32(cur)) segm.min_area = *(int *)mxGetData(cur);
			} else if (name_field == "min_duration") {
                if (mxIsInt32(cur)) segm.min_duration = *(int *)mxGetData(cur);
			}
		}
	}
	
	if (mxIsNumeric(prhs[0]))
	{
		astro = new astrocyte(log_update);
		video_data df_f0_video;
		const mxArray * input_video = prhs[0];
		int img_type;
        if (mxIsSingle(input_video))
        {
            img_type = CV_32FC1;
        }
        else
        {
            mexErrMsgIdAndTxt("MyToolbox:find_events:help", help.c_str());
        }
        int num = (int)mxGetNumberOfDimensions(input_video);
        const mwSize *sz = mxGetDimensions(input_video);
		if (num == 3)
		{
			df_f0_video.reset((uchar *)mxGetData(input_video),
				(int)sz[1], (int)sz[0], (int)sz[2], img_type, false);
		}
		else
		{
			mexErrMsgIdAndTxt("MyToolbox:find_events:help", help.c_str());
		}
		mexEvalString("drawnow;");
		astro->settings(segm);
		astro->build_events(df_f0_video);
	}

	if (nlhs > 0)
	{	
		astro->get_3d_events();
		astro->get_events_info();
		astro->filter_events();
		auto & events_3d_unordered = astro->selected_events_3d;
		std::map<int, std::vector <video_point>> events_3d(events_3d_unordered.begin(), events_3d_unordered.end());
		// Return events
		// Cell array where each cell is event
		// Each event is numeric array with 3 numbers per row - pixel coordinates of events
		const char * field_names_event_3d[] = { "ids", "points" };
		const char * field_names[] = { "x", "y", "t" };
		size_t dims[1] = { 1 };
		mxArray * events_3d_strarr = mxCreateStructArray(1, dims, 2, field_names_event_3d);
		if (events_3d.size() > 0)
		{
			size_t dims[2] = { events_3d.size(), 1 };
			mxArray * value = mxCreateNumericArray(2, dims, mxINT32_CLASS, mxREAL);
			mxArray * pa = mxCreateCellArray(1, dims);
			int k = 0;
			for (auto e : events_3d)
			{
				*((int *)mxGetPr(value) + k) = e.first;

				size_t n = (int)e.second.size();
				size_t dims[2] = { n, 3 };
				mxArray * pa_cur = mxCreateNumericArray(2, dims, mxUINT16_CLASS, mxREAL);
				for (size_t i = 0; i < n; i++)
				{
					*((ushort *)mxGetPr(pa_cur) + i) = e.second[i].x;
					*((ushort *)mxGetPr(pa_cur) + i + n) = e.second[i].y;
					*((ushort *)mxGetPr(pa_cur) + i + n + n) = e.second[i].t;
				}
				mxSetCell(pa, k++, mxDuplicateArray(pa_cur));
				mxDestroyArray(pa_cur);
			}
			mxSetField(events_3d_strarr, 0, "ids", mxDuplicateArray(value));
			mxDestroyArray(value);

			mxSetField(events_3d_strarr, 0, "points", mxDuplicateArray(pa));
			mxDestroyArray(pa);
		}
		plhs[0] = mxDuplicateArray(events_3d_strarr);
		mxDestroyArray(events_3d_strarr);
	}
	if (nlhs > 1) 
	{		
		auto info = astro->selected_components;
		sort(info.begin(), info.end(), [](const component & a, const component & b) { return a.key < b.key; });
		const int CNT_INFO_FIELDS = 6;
		const char * info_field_names[CNT_INFO_FIELDS] = 
			{ "number", "ids", "starts", "finishes", 
			  "durations", "max_projections" };
		size_t dims[1] = { 1 };
        mxArray * pa_cur = mxCreateStructArray(1, dims, CNT_INFO_FIELDS, info_field_names);
		{
			size_t dims[2] = { info.size(), 1 };
			mxArray * value = mxCreateNumericArray(2, dims, mxINT32_CLASS, mxREAL);
			for (int i = 0; i < info.size(); i++) 
				*((int *)mxGetPr (value) + i) = info[i].key;
			mxSetField(pa_cur, 0, "ids", mxDuplicateArray(value));
            mxDestroyArray(value);

			value = mxCreateNumericArray(2, dims, mxINT32_CLASS, mxREAL);
            for (int i = 0; i < info.size(); i++)
            {
                *((int *)mxGetPr(value) + i) = info[i].start;
            }
			mxSetField(pa_cur, 0, "starts", mxDuplicateArray(value));
			mxDestroyArray (value);

			value = mxCreateNumericArray(2, dims, mxINT32_CLASS, mxREAL);
            for (int i = 0; i < info.size(); i++)
            {
                *((int *)mxGetPr(value) + i) = info[i].finish;
            }
            mxSetField(pa_cur, 0, "finishes", mxDuplicateArray(value));
            mxDestroyArray(value);

			value = mxCreateNumericArray(2, dims, mxINT32_CLASS, mxREAL);
            for (int i = 0; i < info.size(); i++)
            {
                *((int *)mxGetPr(value) + i) = info[i].len();
            }
            mxSetField(pa_cur, 0, "durations", mxDuplicateArray(value));
            mxDestroyArray(value);

			value = mxCreateNumericArray(2, dims, mxINT32_CLASS, mxREAL);
            for (int i = 0; i < info.size(); i++)
            {
                *((int *)mxGetPr(value) + i) = info[i].max_projection;
            }
            mxSetField(pa_cur, 0, "max_projections", mxDuplicateArray(value));
            mxDestroyArray(value);

			dims[0] = 1;
			value = mxCreateNumericArray(1, dims, mxINT32_CLASS, mxREAL);
			*(int *)mxGetPr (value) = (int)info.size();
			mxSetField(pa_cur, 0, "number", mxDuplicateArray(value));
			mxDestroyArray(value);
		}
		plhs[1] = mxDuplicateArray(pa_cur);
		mxDestroyArray(pa_cur);
	}
	if (astro != nullptr) delete astro;
}

#include <uchar.h>
#include "mex.h"
#include "mat.h"
#include "astrocyte.h"

std::string help =
"First argument = df_f0 (matrix n x m x nt) of dF/F0 video.\n \
Last argument = params to algo (struct segmentation_settings)\n \
params = struct('a', " + to_string (LENGTH_A) + ", " + 
"'min_points', " + to_string (MIN_POINTS) + ", " + 
"'eps', " + to_string (EPS) + ", " + 
"'thr_area', " + to_string (THR_AREA) + ", " + 
"'thr_time', " + to_string (THR_TIME) + ", " + 
"'min_area', " + to_string (MIN_AREA) + ", " + 
"'min_duration', " + to_string (MIN_DURATION) + ");";

void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	if (nrhs == 0) {
		mexErrMsgIdAndTxt ("MyToolbox:find_events:help", help.c_str());
	}
	
	std::string var_name = "";
	if (nrhs > 1 && mxIsChar (prhs[1]))
		var_name = (char *) mxGetPr(prhs[1]);
	auto log_update = [](const logger & lg) {
		if (lg.get_history ().empty ()) return;
		const vector <record> v = lg.get_history ();
		const auto & last = lg.get_history ().back ();
		using namespace std::chrono;
		char buff[100];
		
		milliseconds ms = duration_cast<milliseconds>(last.log_time),
					 dif(0), duration(0);
		if (lg.get_history().size() > 1)
		{
			dif = duration_cast<milliseconds>(last.log_time - 
					(lg.get_history().end() - 2)->log_time);
		}
		if (lg.get_history().size() > 1)
		{
			duration = duration_cast<milliseconds>(last.log_time - 
				     lg.get_history().begin()->log_time);
		}
		std::string message = std::wstring_convert<
			std::codecvt_utf8<wchar_t>> ().to_bytes (last.message);
		time_t sec = duration_cast<seconds>(last.log_time).count ();
		tm * t = localtime (&sec);
		strftime (buff, 100, "%Y-%m-%d %H:%M:%S", t);
		mexPrintf ("%s.%03d | elapsed %7I64d ms | elapsed from start %7I64d ms | %s\n",
			buff, ms % 1000, dif, duration, message.c_str ());
		mexEvalString ("drawnow;");
	};
	
	astrocyte * astro = nullptr;
	segmentation_settings segm;
	if (mxIsStruct (prhs[nrhs - 1])) {
		const mxArray * param = prhs[nrhs - 1];
		int cnt = mxGetNumberOfFields (param);
		for (int i = 0; i < cnt; i++) {
			std::string name_field = mxGetFieldNameByNumber (param, i);
			mxArray * cur = mxGetFieldByNumber (param, 0, i);
			if (name_field == "a") {
				if (mxIsInt32 (cur)) segm.a = *(int *)mxGetData (cur);
			} else if (name_field == "min_points") {
				if (mxIsInt32 (cur)) segm.min_points = *(int *)mxGetData (cur);
			} else if (name_field == "eps") {
				if (mxIsInt32 (cur)) segm.eps= *(int *)mxGetData (cur);
			} else if (name_field == "thr_area") {
				if (mxIsDouble (cur)) segm.thr_area = *(double *)mxGetData (cur);
			} else if (name_field == "thr_time") {
				if (mxIsDouble (cur)) segm.thr_time = *(double *)mxGetData (cur);
			} else if (name_field == "min_area") {
				if (mxIsInt32 (cur)) segm.min_area = *(int *)mxGetData (cur);
			} else if (name_field == "min_duration") {
				if (mxIsInt32 (cur)) segm.min_duration = *(int *)mxGetData (cur);
			}
		}
	}
	
	
	if (mxIsNumeric (prhs[0])) 
	{
		astro = new astrocyte (log_update);
		video_data df_f0_video;
		const mxArray * input_video = prhs[0];
		int img_type;
		if (mxIsUint8 (input_video)) img_type = CV_8UC1;
		else mexErrMsgIdAndTxt ("MyToolbox:find_events:help", help.c_str ());
		int num = (int)mxGetNumberOfDimensions (input_video);
		const mwSize *sz = mxGetDimensions (input_video);
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
		mexPrintf("settings: a = %d min_points = %d eps = %d thr_area = %lf thr_time = %lf min_area = %d min_duration = %d\n", 
			segm.a, segm.min_points, segm.eps, segm.thr_area, segm.thr_time,
			segm.min_area, segm.min_duration);
		astro->build_events(df_f0_video);
	}

	if (nlhs > 0)
	{	
		astro->get_3d_events();
		astro->get_events_info();
		astro->filter_events();
		auto & events_3d = astro->selected_events_3d;
		mexPrintf("Number of events: %d\n", events_3d.size());
		// Return events
		// Cell array where each cell is event
		// Each event is numeric array with 3 numbers per row - pixel coordinates of events
		const char * field_names_event_3d[] = { "ids", "points" };
		const char * field_names[] = { "x", "y", "t" };
		size_t dims[1] = { events_3d.size() };
		mxArray * events_3d_strarr = mxCreateStructArray(1, dims, 2, field_names_event_3d);
		{
			size_t dims[2] = { events_3d.size(), 1 };
			mxArray * value = mxCreateNumericArray(2, dims, mxINT32_CLASS, mxREAL);
			mxArray * pa = mxCreateCellArray(1, dims);
			int k = 0;
			for (auto e : events_3d)
			{
				*((int *)mxGetPr(value) + k) = e.first;

				int n = (int)e.second.size();
				size_t dims[2] = { n, 3 };
				mxArray * pa_cur = mxCreateNumericArray(2, dims, mxUINT16_CLASS, mxREAL);
				for (int i = 0; i < n; i++)
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
		mexPrintf("Number of proccessed events: %d\n", info.size());
		const int CNT_INFO_FIELDS = 6;
		const char * info_field_names[CNT_INFO_FIELDS] = 
			{ "numbers", "ids", "starts", "finishes", 
			  "durations", "max_projections" };
		size_t dims[1] = { 1 };
		mxArray * pa_cur = mxCreateStructArray (1, dims, CNT_INFO_FIELDS, info_field_names);
		{
			size_t dims[2] = { info.size(), 1 };
			mxArray * value = mxCreateNumericArray(2, dims, mxINT32_CLASS, mxREAL);
			for (int i = 0; i < info.size (); i++) 
				*((int *)mxGetPr (value) + i) = info[i].key;
			mxSetField(pa_cur, 0, "ids", mxDuplicateArray(value));
			mxDestroyArray (value);

			value = mxCreateNumericArray(2, dims, mxINT32_CLASS, mxREAL);
			for (int i = 0; i < info.size (); i++) 
				*((int *)mxGetPr (value) + i) = info[i].start;
			mxSetField(pa_cur, 0, "starts", mxDuplicateArray(value));
			mxDestroyArray (value);

			value = mxCreateNumericArray(2, dims, mxINT32_CLASS, mxREAL);
			for (int i = 0; i < info.size (); i++) 
				*((int *)mxGetPr (value) + i) = info[i].finish;
			mxSetField(pa_cur, 0, "finishes", mxDuplicateArray (value));
			mxDestroyArray (value);

			value = mxCreateNumericArray(2, dims, mxINT32_CLASS, mxREAL);
			for (int i = 0; i < info.size (); i++) 
				*((int *)mxGetPr (value) + i) = info[i].len ();
			mxSetField(pa_cur, 0, "durations", mxDuplicateArray (value));
			mxDestroyArray (value);

			value = mxCreateNumericArray(2, dims, mxINT32_CLASS, mxREAL);
			for (int i = 0; i < info.size (); i++) 
				*((int *)mxGetPr (value) + i) = info[i].max_projection;
			mxSetField(pa_cur, 0, "max_projections", mxDuplicateArray (value));
			mxDestroyArray (value);

			dims[0] = 1;
			value = mxCreateNumericArray(1, dims, mxINT32_CLASS, mxREAL);
			*(int *)mxGetPr (value) = (int)info.size();
			mxSetField(pa_cur, 0, "numbers", mxDuplicateArray(value));
			mxDestroyArray (value);
		}
		plhs[1] = mxDuplicateArray (pa_cur);
		mxDestroyArray (pa_cur);
	}
	delete astro;
}
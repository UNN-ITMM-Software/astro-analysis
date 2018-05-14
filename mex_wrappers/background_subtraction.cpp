#include <uchar.h>
#include <mex.h>
#include <mat.h>

#include "astrocyte.h"

std::string help =
"First argument = video (uint8 matrix n x m x nt) of preprocessed source.\n \
Last argument = params to algo (struct segmentation_settings)\n \
params = struct('thr_df_f0', " + to_string (THR_DF_F0) + ");";

void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	if (nrhs == 0)
    {
		mexErrMsgIdAndTxt ("MyToolbox:find_events:help", help.c_str());
	}
	
	std::string var_name = "";
	auto log_update = [](const logger & lg) {
        if (lg.get_history().empty()) return;
        const vector <record> v = lg.get_history();
        const auto & last = lg.get_history().back();
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
            std::codecvt_utf8<wchar_t>> ().to_bytes(last.message);
        time_t sec = duration_cast<seconds>(last.log_time).count();
        tm * t = localtime(&sec);
		strftime (buff, 100, "%Y-%m-%d %H:%M:%S", t);
        mexPrintf("%s.%03d | elapsed %7I64d ms | elapsed from start %7I64d ms | %s\n",
            buff, ms % 1000, dif, duration, message.c_str());
        mexEvalString("drawnow;");
	};
	int thr_df_f0 = THR_DF_F0;
	if (mxIsStruct (prhs[nrhs - 1]))
    {
		const mxArray * param = prhs[nrhs - 1];
        int cnt = mxGetNumberOfFields(param);
		mexPrintf("int cnt = %d\n", cnt);
		for (int i = 0; i < cnt; i++)
        {
            std::string name_field = mxGetFieldNameByNumber(param, i);
            mxArray * cur = mxGetFieldByNumber(param, 0, i);
			if (name_field == "thr_df_f0")
            {
				if (mxIsInt32(cur))
                {
					thr_df_f0 = *(int *)mxGetData(cur);
					mexPrintf("thr_df_f0 = %d\n", thr_df_f0);
				}
			}
		}
	}

	astrocyte * astro = nullptr;
	video_data preprocessed_video, df_f0_video, back_sub_video, fg_masks;
	if (mxIsNumeric(prhs[0]))
    {
        astro = new astrocyte(log_update);
		const mxArray * input_video = prhs[0];
		int img_type;
		if (mxIsSingle(input_video)) img_type = CV_32FC1;
		else mexErrMsgIdAndTxt("MyToolbox:find_events:help", help.c_str());
		int num = (int)mxGetNumberOfDimensions(input_video);
		const mwSize * sz = mxGetDimensions(input_video);
		if (num == 3) preprocessed_video.reset(
			(uchar *)mxGetData (input_video), (int)sz[1], (int)sz[0], 
			(int)sz[2], img_type, false);
		else mexErrMsgIdAndTxt("MyToolbox:find_events:help", help.c_str());
		astro->background_subtraction(preprocessed_video, df_f0_video,
			back_sub_video, fg_masks, thr_df_f0);
	}
	
	if (nlhs > 0)
    {
		size_t dims[3] = { df_f0_video.m, df_f0_video.n, df_f0_video.nt };
		mxArray * pa = mxCreateNumericArray(3, dims, mxSINGLE_CLASS, mxREAL);
		memcpy(mxGetPr(pa), df_f0_video.get_data(), df_f0_video.size * df_f0_video.type_size);
		plhs[0] = mxDuplicateArray(pa);
		mxDestroyArray(pa);
	}
	if (nlhs > 1)
    {
		size_t dims[3] = { back_sub_video.m, back_sub_video.n, back_sub_video.nt };
		mxArray * pa = mxCreateNumericArray(3, dims, mxUINT8_CLASS, mxREAL);
		memcpy (mxGetPr(pa), back_sub_video.get_data(), back_sub_video.size * back_sub_video.type_size);
		plhs[1] = mxDuplicateArray(pa);
		mxDestroyArray(pa);
	}
    if (nlhs > 2)
    {
        size_t dims[3] = { fg_masks.m, fg_masks.n, fg_masks.nt };
        mxArray * pa = mxCreateNumericArray(3, dims, mxUINT8_CLASS, mxREAL);
        memcpy(mxGetPr(pa), fg_masks.get_data(), fg_masks.size);
        plhs[2] = mxDuplicateArray(pa);
        mxDestroyArray(pa);
    }
	delete astro;
}

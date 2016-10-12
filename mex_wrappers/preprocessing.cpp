#include <uchar.h>
#include "mex.h"
#include "mat.h"
#include "astrocyte.h"

std::string help =
"First argument = video (double matrix n x m x nt) of source.\n";

void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	if (nrhs == 0) {
		mexErrMsgIdAndTxt ("MyToolbox:find_events:help", help.c_str());
	}
	
	std::string var_name = "";
	auto log_update = [](const logger & lg) {
		if (lg.get_history ().empty ()) return;
		const vector <record> v = lg.get_history ();
		const auto & last = lg.get_history ().back ();
		using namespace std::chrono;
		char buff[100];
		
		milliseconds ms = 
			duration_cast<milliseconds>(last.log_time), dif(0), duration(0);
		if (lg.get_history ().size () > 1) 
			dif = duration_cast<milliseconds>(last.log_time - 
				(lg.get_history ().end () - 2)->log_time);
		if (lg.get_history ().size () > 1) 
			duration = duration_cast<milliseconds>(last.log_time - 
				lg.get_history ().begin ()->log_time);
		std::string message = std::wstring_convert<std::codecvt_utf8<wchar_t>>().
			to_bytes (last.message);
		time_t sec = duration_cast<seconds>(last.log_time).count ();
		tm * t = localtime (&sec);
		strftime (buff, 100, "%Y-%m-%d %H:%M:%S", t);
		mexPrintf ("%s.%03d | elapsed %7I64d ms | elapsed from start %7I64d ms | %s\n", 
			buff, ms % 1000, dif, duration, message.c_str ());
		mexEvalString ("drawnow;");
	};
	astrocyte * astro = nullptr;
	video_data source_video, preprocessed_video;	
	mexEvalString ("drawnow;");
	if (mxIsNumeric (prhs[0])) 
	{		
		mexEvalString ("drawnow;");
		astro = new astrocyte (log_update);
		const mxArray * input_video = prhs[0];
		int img_type;
		if (mxIsDouble (input_video)) img_type = CV_64F;
		else if (mxIsUint16 (input_video)) img_type = CV_16UC1;
		else if (mxIsSingle (input_video)) img_type = CV_32F;
		else mexErrMsgIdAndTxt ("MyToolbox:find_events:help", help.c_str ());
		int num = (int)mxGetNumberOfDimensions (input_video);
		const mwSize *sz = mxGetDimensions (input_video);
		if (num == 3) 
			source_video.reset((uchar *)mxGetData (input_video), 
				(int)sz[1], (int)sz[0], (int)sz[2], img_type, false);
		else mexErrMsgIdAndTxt ("MyToolbox:find_events:help", help.c_str ());
		astro->preprocessing(source_video, preprocessed_video);
	}
	
	if (nlhs > 0) {
		size_t dims[3] = { preprocessed_video.m, preprocessed_video.n, 
			preprocessed_video.nt };
		mxArray * pa = mxCreateNumericArray (3, dims, mxUINT8_CLASS, mxREAL);
		memcpy(mxGetPr (pa), preprocessed_video.get_data (), 
			preprocessed_video.size);
		plhs[0] = mxDuplicateArray(pa);
		mxDestroyArray (pa);
	}
	delete astro;
}
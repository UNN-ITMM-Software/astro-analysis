#include "astrocyte.h"

astrocyte::astrocyte(function <void (const logger & lg)> log_update)
{
	astro_log.register_callback(log_update);
}

astrocyte::~astrocyte ()
{
	if (pos) delete[]pos;
	if (graph) delete[]graph;
}

void astrocyte::normalization(const video_data & source_video,
	video_data & preprocessed_video, const uchar lb, const uchar rb)
{
	astro_log.set_info(L"Normalization.");
    astro_log.set_info(L"Left bound: " + to_wstring(lb));
    astro_log.set_info(L"Right bound: " + to_wstring(rb));
	preprocessed_video.reset(new uchar[source_video.size * source_video.type_size], source_video.n,
		source_video.m, source_video.nt, CV_32F);
	double min_val, max_val;
	minMaxLoc(source_video.image(0), &min_val, &max_val);
	for (int t = 0; t < source_video.nt; t++)
	{
		Mat img = source_video.image(t);
		double min_cur, max_cur;
		minMaxLoc(img, &min_cur, &max_cur);
		min_val = min(min_cur, min_val);
		max_val = max(max_cur, max_val);
	}
	astro_log.set_info(L"Minimum intensity: " + to_wstring(min_val));
	astro_log.set_info(L"Maximum intensity: " + to_wstring(max_val));
	for (int t = 0; t < source_video.nt; t++)
	{
		Mat img = source_video.image(t), img_byte;
		img.convertTo(img_byte, CV_32F, ((double)(rb - lb)) / (max_val - min_val),
			-min_val * ((double)(rb - lb)) / (max_val - min_val) + lb);
		memcpy(preprocessed_video.frame(t), img_byte.data, source_video.nm * source_video.type_size);
	}
	astro_log.set_info(L"~Normalization.");
}

void astrocyte::smoothing(video_data & preprocessed_video, 
	const int l, const int r)
{
	astro_log.set_info(L"Smoothing.");
	vector <float> res, out;
	res.resize(preprocessed_video.nt);
	out.resize(preprocessed_video.nt);	
	for (int i = 0; i < preprocessed_video.n; i++)
	{
		for (int j = 0; j < preprocessed_video.m; j++)
		{
			for (int t = 0; t < preprocessed_video.nt; t++)
			{
				res[t] = preprocessed_video.cell<float>(t, i, j);
			}
			smooth<float, float>(res, out, l, r);
			for (int t = 0; t < preprocessed_video.nt; t++)
			{
				preprocessed_video.cell<float>(t, i, j, out[t]);
			}
		}
	}
	astro_log.set_info(L"~Smoothing.");
}

void astrocyte::preprocessing(const video_data & source_video, 
	video_data & preprocessed_video, const uchar lb, const uchar rb,
    bool smooth_by_time)
{
	astro_log.set_info (L"Preprocessing." L" nt = " + to_wstring (source_video.nt));
	normalization(source_video, preprocessed_video, lb, rb);
	if (!smooth_by_time)
	{
		astro_log.set_info(L"~Preprocessing.");
		return;
	}
	smoothing(preprocessed_video);
	astro_log.set_info (L"~Preprocessing.");
}

void astrocyte::background_subtraction(const video_data & source_video, 
	video_data & df_f0_video, video_data & background_video, video_data & fg_masks,
    int thr_df_f0)
{
	astro_log.set_info (L"Background subtraction.");
	BackgroundSubtractorMOG2 bg_model;
	//BackgroundSubtractorMOG2 bg_model(300, 8.0f, false);

	df_f0_video.reset(new uchar[source_video.size * source_video.type_size], 
		source_video.n, source_video.m, source_video.nt, source_video.img_type);
	background_video.reset(new uchar[source_video.size], 
		source_video.n, source_video.m, source_video.nt, CV_8U);
	fg_masks.reset(new uchar[source_video.size], source_video.n,
        source_video.m, source_video.nt, CV_8U);
	
	astro_log.set_info(L"Construct background model.");
	segm.thr_df_f0 = thr_df_f0;
	astro_log.set_info(L"Threshold: " + to_wstring(segm.thr_df_f0));
	for (int t = 0; t < source_video.nt; t++)
	{
		Mat img = source_video.image(t), fg_mask;
		bg_model(img, fg_mask);
	}
	astro_log.set_info(L"~Construct background model.");
	
	astro_log.set_info(L"Construct background model.");
	for (int t = 0; t < source_video.nt; t++)
	{
		Mat img = source_video.image(t), fg_mask, bg_img;
		bg_model(img, fg_mask);
		bg_model.getBackgroundImage(bg_img);
		memcpy(background_video.frame(t), bg_img.data, background_video.nm * background_video.type_size);
        memcpy(fg_masks.frame(t), fg_mask.data, fg_masks.nm * fg_masks.type_size);
	}
	astro_log.set_info(L"~Construct background model.");
	astro_log.set_info(L"~Background subtraction.");
}

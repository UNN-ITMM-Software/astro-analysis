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
	preprocessed_video.reset(new uchar[source_video.size], source_video.n,
		source_video.m, source_video.nt, CV_8U);
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
		img.convertTo(img_byte, CV_8U, ((double)(rb - lb)) / (max_val - min_val),
			-min_val * ((double)(rb - lb)) / (max_val - min_val) + lb);
		memcpy(preprocessed_video.frame(t), img_byte.data, source_video.nm);
	}
	astro_log.set_info(L"~Normalization.");
}

void astrocyte::smoothing(video_data & preprocessed_video, 
	const int l, const int r)
{
	astro_log.set_info(L"Smoothing.");
	vector <uchar> res, out;
	res.resize(preprocessed_video.nt);
	out.resize(preprocessed_video.nt);	
	for (int i = 0; i < preprocessed_video.n; i++)
	{
		for (int j = 0; j < preprocessed_video.m; j++)
		{
			for (int t = 0; t < preprocessed_video.nt; t++)
			{
				res[t] = preprocessed_video.cell(t, i, j);
			}
			smooth<uchar, int>(res, out, l, r);
			for (int t = 0; t < preprocessed_video.nt; t++)
			{
				preprocessed_video.cell(t, i, j, out[t]);
			}
		}
	}
	astro_log.set_info(L"~Smoothing.");
}

void astrocyte::preprocessing(const video_data & source_video, 
	video_data & preprocessed_video, bool smooth_by_time)
{
	astro_log.set_info (L"Preprocessing." L" nt = " + to_wstring (source_video.nt));
	normalization(source_video, preprocessed_video);
	if (!smooth_by_time)
	{
		astro_log.set_info(L"~Preprocessing.");
		return;
	}
	smoothing(preprocessed_video);
	astro_log.set_info (L"~Preprocessing.");
}

void astrocyte::background_subtraction (const video_data & source_video, 
	video_data & df_f0_video, video_data & background_video, int thr_df_f0)
{
	astro_log.set_info (L"Background subtraction.");
	BackgroundSubtractorMOG2 bg_model;
	df_f0_video.reset(new uchar[source_video.size], source_video.n, 
		source_video.m, source_video.nt, CV_8U);
	background_video.reset(new uchar[source_video.size], source_video.n,
		source_video.m, source_video.nt, CV_8U);
	double all_min = 1e9, all_max = -1e9;
	astro_log.set_info(L"Construct background model.");
	segm.thr_df_f0 = thr_df_f0;
	astro_log.set_info(L"Threshold: " + to_wstring(segm.thr_df_f0));
	for (int t = 0; t < source_video.nt; t++)
	{
		Mat img = source_video.image(t), fg_mask, bg_img;
		bg_model(img, fg_mask);
		bg_model.getBackgroundImage(bg_img);

		Mat img_df_f, img_f, bgimg_f;
		img.convertTo(img_f, CV_32F);
		bg_img.convertTo(bgimg_f, CV_32F);
		img_df_f = max((img_f - bgimg_f) / (bgimg_f), 0);

		double min_cur, max_cur;
		minMaxLoc(img_df_f, &min_cur, &max_cur);
		all_min = min(min_cur, all_min);
		all_max = max(all_max, max_cur);
	}
	astro_log.set_info(L"Minimum intensity: " + to_wstring(all_min));
	astro_log.set_info(L"Maximum intensity: " +	to_wstring(all_max));
	astro_log.set_info(L"~Construct background model.");
	
	astro_log.set_info(L"Compute df/f0 for each video frame.");
	for (int t = 0; t < source_video.nt; t++)
	{
		Mat img = source_video.image(t), fg_mask, bg_img;
		bg_model(img, fg_mask);
		bg_model.getBackgroundImage(bg_img);

		Mat img_df_f, img_f, bgimg_f;
		img.convertTo(img_f, CV_32F);
		bg_img.convertTo(bgimg_f, CV_32F);
		img_df_f = max((img_f - bgimg_f) / (bgimg_f), 0);

		Mat img_df_f_b;
		img_df_f.convertTo(img_df_f_b, CV_8U, 255.0 / (all_max - all_min),
			-255.0 * all_min / (all_max - all_min));

		// Threshold
		img_df_f_b = max(img_df_f_b, segm.thr_df_f0);
		img_df_f_b.convertTo(img_df_f_b, CV_8U, 1.0, -segm.thr_df_f0);
		img_df_f_b.convertTo(img_df_f_b, CV_8U, 255.0 / (255.0 - segm.thr_df_f0), 0.0);
		memcpy(df_f0_video.frame(t), img_df_f_b.data, df_f0_video.nm);
		memcpy(background_video.frame(t), bg_img.data, background_video.nm);
	}
	astro_log.set_info(L"~Compute df/f0 for each video frame.");
	astro_log.set_info(L"~Background subtraction.");
}
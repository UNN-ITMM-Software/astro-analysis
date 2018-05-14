% par.Nthr = 2.4  ;  [ 1 : 0.2 :  4 ] - диапазон от 1 до 4 с шагом 0.2,
% par.F0_smooth_primal_sec = 300 ;  [ 100 : 20 : 500 ]
% par.F0_smooth_sec = 100 ; [ 50 : 20 : 150 ]
% par.Nthr_dFF = 2.4 ; [ 1 : 0.2 : 4 ]
% eval_gen_Ca2_Astro_2('2.4', '300', '100', '2.4', 'F:\PC\Document Files\UNN\3 course\Coursework\Data\2015.04.28\2013-05-22_fileNo03\2013-05-22_fileNo03_z-max_bm3d.mat','F:\PC\Document Files\UNN\3 course\Coursework\Data\2015.04.28\2013-05-22_fileNo03\', '4');

function [Ca_dFF, Caf, Ca_Bif, Ca_F0, Events, Events_3d, time_yu_wei_find_events] = eval_gen_Ca2_Astro_2(par, input_video)
    
    %% Parameters
    
    par.UNN_events_detection = true;
    % par.BM3D_filtering = true ;
    par.High_pass_filtering = false;
    par.Events_high_pass_freq = 0.02; % to find events we filter low-freq first [ Hz ] 0.02 = 50 se ;
    par.Low_pass_filtering = false;
    par.Events_low_pass_freq = 0.25; % to find events we filter
    par.Decimate_images = false;
    par.Decimate_factor = 3.0;
    par.Wavelet_filtering = false;
    
    % MAIN detection parameters
    par.type = 2;
    par.Nthr; % stat threshold Coeff. for event detection , phase 1
    par.F0_smooth_primal_sec; % primal phase, remove trend smooth window
    par.F0_smooth_sec; % smooth parameter to estimate F0 after phase 1 event cut [ sec ]
    par.Nthr_dFF; % stat threshold Coeff. for dF/F0 event detection , phase 2
    par.Nthr_dFF_max_min = 2.0; % [ % ] event dF/F0 max - min / min = threshold to filter small events
    dff_abs_thres = 2.0; % [ % ] - set minimum dF/F0 event threshold
    dF_F0_limit = 1500; % [ % ] - limit
    mean_Ca_thresh = 1 / 1000; % [ % ] - limit
    smooth_Ca_signals_dFF = false;
    
    Event_min_integral = 6 * 2; % MeanIntensity Area = [ um^2 * sec ]
    Event_min_duration = 2; % [seconds]
    Event_min_Size = 2; % [um] each image filter small area, not important
    
    % parameters from Ca2_Astro_2.m
    par.erase_no_events_Ca = true; % necessary to detect events next
    par.Get_activity_skeleton = true; % statistics of the events on 2d image
    par.fast_analysis = true; % false - shows sample plots of how events detected, runs slower
    par.extract_events = false; % show event samples
    par.MakingLoop = false;
    par.additional_processing = true; % from old script - alpha value estimation
    
    par.test_fixed_frames = 0; % takes on defined number of frames
    par.show_stack_matVi = false; % after all filtering/detection is done show stack
    par.save_stacks_Ca = true; % save( 'Ca_stacks.mat' , 'Caf' , 'Ca_Bif' , 'Ca_dFF' ); after filtering
    par.save_Eventsinfo = true;
    
    parfor_d = 2400; % parfor parameter for parfor loop split
    par.saveRes = true;
    
    % from ...script_1.m
    par.FRET = false;
    par.ROIs_only = false;
    par.Ca2.gen = true;
    par.Ca2.alpha_analysis = true;
    par.Ca2.Ca2_movie_generation = false;
    par.application = false;
    par.saveFig = false;
    
    % acq.time = 0.434930555522442 ;
    % acq.time =  0.5009 ;
    if exist('xt', 'var')
        framerate = (length(xt) - 1) / (xt(end) - xt(1)) / 60;
        acq.time = 1 / framerate;
    else
        acq.time = 0.5009; % Framrate
        % acq.time =  2.7398 ;
    end
    acq.mcm_per_pix = 0.222; % micrometers per pixel
    
    if par.Decimate_images
        acq.mcm_per_pix = acq.mcm_per_pix * par.Decimate_factor;
    end
    
    %---- Start --------------------------------------
    Naps = 1;
    Event_min_duration = floor(Event_min_duration / acq.time);
    Event_min_Size = Event_min_Size / acq.mcm_per_pix.^2;
    Event_min_integral = Event_min_integral / (acq.mcm_per_pix.^2 * acq.time);
    
    showed_figure = false;
    %close all
    
    % test pixel for sample of signal filtering and evemt detection
    show_selected_pixel_analysis = false;
    yyy = 146;
    xxx = 97;
    
    % Main image stack for analysis should be in "dbg" variable
    
    % dbg = Branch ;
    % dbg = dbgm ; % clear dbgm ;
    % dbg = z ; clear z ;
    % dbg = uint16( dbg ) ;
    
    % dbg( : , : , 1 : 100 ) = [] ;
    
    % load (file_name);
    % dbg = data_zmax_bm3d;
    % clear data_zmax_bm3d
    % whos dbg
    
    dbg = input_video;
    
    tStart = tic; %Timer start
    t1 = toc(tStart);
    
    %% for parallel computing
    
    %myCluster = parcluster('local');
    %parpool(str2num(num_threads));
    
    % if isempty(gcp('nocreate'))
    %   % disp('isempty');
    % options.Interpreter = 'tex';
    % options.Default = 'Yes';
    %   %if strcmp('Yes',questdlg({'matlabpool not started yet!';'Start it now?'},'Multicore Condition','Yes','No',options))
    %     parpool('local',4);
    %     % gcp ();
    %   %end
    %   clear options
    % end
    par.ParforProgress2 = false;
    %if ~isempty(gcp('nocreate'))
    %   disp('else');
    %   functionname='ParforProgress2.m';
    %   functiondir=which(functionname);
    %   if ~isempty(functiondir)
    %     par.ParforProgress2 = true;
    %     functiondir = functiondir(1:end-length(functionname));
    %     addpath(functiondir);
    %     %#function pctRunOnAll
    %     %#function javaaddpath
    %     % eval(sprintf('pctRunOnAll javaaddpath ''%s''', functiondir))
    %     pctRunOnAll javaaddpath()
    %   end
    %end
    clear functionname functiondir
    t1 = output('checked matlabpool', whos, toc(tStart), t1);
    
    %% UNN - Filter stack and decimate
    
    t1 = output('spat.-freq. filtering stack started', whos, toc(tStart), t1);
    if par.test_fixed_frames > 0
        dbg(:, :, par.test_fixed_frames:end) = [];
    end
    
    %---Decimate_images
    if par.Decimate_images
        image_origin = dbg(:, :, 1);
        scale_factor = par.Decimate_factor;
        s = size(dbg);
        tm = s(3);
        numrows = floor(s(1) / scale_factor);
        numcols = floor(s(2) / scale_factor);
        
        b_r = zeros(numrows, numcols, s(3));
        for ti = 1:tm
            b_r(:, :, ti) = imresize(dbg(:, :, ti), [numrows, numcols], 'bicubic');
        end
        dbg = b_r;
        clear b_r;
        
        if ~par.fast_analysis
            figure
            Nx = 2;
            Ny = 1;
            subplot(Ny, Nx, 1)
            imagesc(image_origin);
            colorbar;
            axis square;
            title('Original image')
            subplot(Ny, Nx, 2)
            imagesc(dbg(:, :, 1));
            colorbar;
            axis square;
            title('Image resized')
            clear image_origin;
        end
    end
    %---------------------
    
    sz = size(dbg);
    N = sz(2);
    Ca = dbg;
    acq.minutes_num = (sz(3) * acq.time) / 60;
    if par.High_pass_filtering
        fmin_detect = par.Events_high_pass_freq; % par.Events_high_pass_freq ; %  0.05 Hz ;
        
        %            if ~isfield( acq , 'Sr' )
        acq.Sr = 1 / acq.time;
        %            end
        [b, a] = ellip(2, 0.1, 40, fmin_detect * 2 / acq.Sr, 'high');
        
        %%pfpm = ParforProgress2('varif(z,[0 0 win],''rectangular'')', N, 1, 0, 1);
        %           parfor nn=1:N %par
        %             figure
        for yy = 1:sz(1) %par
            parfor xx = 1:sz(2) %par
                y = double(squeeze(dbg(yy, xx, :)));
                mean_y = mean(y);
                filt_t = filtfilt(b, a, y - mean_y);
                %                 plot( filt_t );
                Ca(yy, xx, :) = single(filt_t + mean_y);
            end
            %%pfpm.increment(i);
        end
        %%pfpm.delete();
        
        %             matVis( Ca );
        figure;
        hold on
        
        %         plot( squeeze( dbg( xxx ,yyy,:) - mean(dbg( xxx,yyy,:)) ) );
        plot(squeeze(dbg(xxx, yyy, :)));
        plot(squeeze(Ca(xxx, yyy, :)), 'r');
        legend('original', 'filtered')
        hold off
        
    end
    
    %-----Low_pass_filtering
    if par.Low_pass_filtering
        fmax_detect = par.Events_low_pass_freq; % par.Events_high_pass_freq ; %  0.05 Hz ;
        
        %            if ~isfield( acq , 'Sr' )
        acq.Sr = 1 / acq.time;
        %            end
        [b, a] = ellip(2, 0.1, 40, fmax_detect * 2 / acq.Sr, 'low');
        
        %%pfpm = ParforProgress2('varif(z,[0 0 win],''rectangular'')', N, 1, 0, 1);
        %           parfor nn=1:N %par
        %             figure
        for yy = 1:sz(1) %par
            parfor xx = 1:sz(2) %par
                y = double(squeeze(Ca(yy, xx, :)));
                mean_y = mean(y);
                filt_t = filtfilt(b, a, y - mean_y);
                %                 plot( filt_t );
                Ca(yy, xx, :) = single(filt_t + mean_y);
            end
            %%pfpm.increment(i);
        end
        %%pfpm.delete();
        
        figure;
        hold on
        
    end
    %-- Wavelet filtering
    if par.Wavelet_filtering
        %         plot( squeeze( dbg( xxx ,yyy,:) - mean(dbg( xxx,yyy,:)) ) );
        tx = acq.time;
        plot(tx * (1:sz(3)), squeeze(dbg(xxx, yyy, :)));
        plot(tx * (1:sz(3)), squeeze(Ca(xxx, yyy, :)), 'r');
        legend('original', 'filtered')
        hold off
        
        %         xxx2 = 66 ; yyy2 = 42 ;
        xxx2 = xxx;
        yyy2 = yyy;
        
        Fs = 1 / acq.time; % samplerate
        Morlet_w0 = 6; % order of morlet wavelet
        Wavelet_freq = [0.001 : 0.001 : 0.2]; % frequencies for wavelet analysis
        Wavelet_freq_durations = 1 ./ Wavelet_freq;
        %             CWTcoeffs = cwt(y,1:64,'haar','plot'); colormap jet;
        [cw1, sc] = cwt(y, 32:232, 'sym2', 'scal');
        
        %             y=squeeze( Ca( xxx ,yyy ,:) )  ;
        y = squeeze(Ca(xxx2, yyy2, :));
        t = 1:sz(3);
        t = (t - 1) * acq.time;
        [coef, scales] = morlet_custom(y, Fs, Wavelet_freq, Morlet_w0);
        Wavelts = abs(coef);
        figure
        Nx = 1;
        Ny = 2;
        h1 = subplot(Ny, Nx, 1);
        plot(t, y)
        xlabel('Time, sec')
        title('Signal')
        xlim([1, max(t)])
        h2 = subplot(Ny, Nx, 2);
        pcolor(t, Wavelet_freq, Wavelts);
        %                     pcolor(t  , Wavelet_freq_durations , Wavelts );
        %                     pcolor(t  , scales , Wavelts );
        
        %         plot(t  , Wavelts );
        shading flat;
        grid off;
        axis('xy'); % flip the vertical axis over
        xlim([1, max(t)])
        xlabel('Time');
        ylabel('Frequency,Hz');
        title('Wavelet transform')
        %colorbar
        linkaxes([h1, h2], 'x')
        
        stopHere
        
    end
    
    if par.fast_analysis
        clear dbg
    end
    
    Caf_mean = mean(Ca, 3);
    %---------
    
    %% UNN - loop some parameter for test
    fn = 0;
    % par.Nthr_dFF = 0.6 ;
    
    for LoopA = 1:1
        fn = fn + 1;
        % par.Nthr_dFF = par.Nthr_dFF + 0.2 ;
        
        %% Data evaluation
        if ~par.ROIs_only
            if par.Ca2.gen % Ca2+ signal analysis
                
                %% Alpha Value Analysis
                if par.Ca2.alpha_analysis
                    t1 = output('ALPHA START ANALYSIS', whos, toc(tStart), t1);
                    BG = 0;
                    
                    %% Application specific analysis
                    for naps = 1:Naps
                        %             if run_all_script
                        
                        %% UNN - find thresholds for events
                        
                        % Estimate threshold T = med( | X | )/0.6745 , it's the same as
                        % T=std( X ), but less depends on event frequency (Quiroga et.
                        % al.,2004)
                        s = size(Ca);
                        Ca_thr = zeros(s(1), s(2));
                        timepoints_num = s(3);
                        
                        %         Ca_mean0 = median( Ca , 3 ) ;
                        %         Ca_no_mean = Ca ;
                        %         for ti=1:sz(3)
                        %             Ca_no_mean(:,:,ti) = Ca(:,:,ti)  - Ca_mean0  ;
                        %         end
                        
                        for yy = 1:floor(sz(1))
                            parfor xx = 1:sz(2) %par
                                Ca_mean0 = median(squeeze(Ca(yy, xx, :)));
                                Ca_no_mean = squeeze(Ca(yy, xx, :)) - Ca_mean0;
                                if Ca_mean0 < mean_Ca_thresh
                                    Ca_thr(yy, xx) = 0;
                                else
                                    Ca_thr(yy, xx) = par.Nthr * median(abs(Ca_no_mean)) / 0.6745 + Ca_mean0;
                                end
                                
                            end
                        end
                        Ca_thr(Ca_thr < 0) = 0;
                        
                        %         Ca_thr  = par.Nthr * median( abs(Ca_no_mean) , 3)/ 0.6745 + Ca_mean0  ;
                        %         Ca_thr = squeeze( Ca_thr );
                        %         clear Ca_mean0
                        
                        %         line=squeeze( Ca( xxx, yyy , :)) ;
                        %         figure; hold on
                        %             plot( line , 'k') ;
                        %             base_line0 =   Ca_mean0( xxx , yyy  ) ;
                        %             plot( [ 0 length(line)] ,  [ base_line0 base_line0  ] , 'b') ;
                        %             thr = Ca_thr( xxx , yyy  )  ;
                        %             plot( [ 0 length(line)] ,  [ thr thr  ] , 'r') ;
                        %         legend( 'signal', 'base line' , 'Threshold' )
                        %         figure ; imgagesc(  Ca_median ) ; colorbar ;
                        
                        %% UNN - detect pulses in each pixel, find F0, dF/F0
                        
                        t1 = output('Event detection each pixel started', whos, toc(tStart), t1);
                        
                        %         profile on
                        z = squeeze(max(Ca, [], 3));
                        sz = size(z);
                        [ys, xs] = size(z);
                        Smooth_window = floor(par.F0_smooth_sec / acq.time); % if Bin = 0.5 sec and smooth 10 sec , then window = 20 frames ;
                        Smooth_window_prime = floor(par.F0_smooth_primal_sec / acq.time);
                        sz_stack = size(Ca);
                        Ca = shiftdim(Ca, 2);
                        Ca_F0 = Ca;
                        %         Ca_dFF = Ca  ;
                        %        Ca_F0 = shiftdim( Ca , 2 ) ;
                        %        Ca_dFF = shiftdim( Ca , 2 ) ;
                        
                        if ~par.fast_analysis
                            %        Ca = shiftdim( Ca , 2 ) ;
                        end
                        
                        estart = cell(sz(1), sz(2));
                        eend = cell(sz(1), sz(2));
                        emax = cell(sz(1), sz(2));
                        events_num = zeros(sz(1), sz(2));
                        
                        dd = whos('Ca');
                        [~, sys] = memory;
                        dnn = min([xs, floor(xs * sys.PhysicalMemory.Available / dd.bytes / 22)]);
                        
                        % %pfpm = ParforProgress2('varif(z,[0 0 win],''rectangular'')', N, 1, 0, 1);
                        dnn = parfor_d;
                        for sxx = 1:dnn:xs %parfor
                            dnn = min([dnn, xs - sxx + 1]);
                            nsub = sxx - 1 + (1:dnn);
                            %          for xx= nsub  %parfor
                            parfor xx = nsub %parfor
                                xx;
                                for yy = 1:ys
                                    Casignal = squeeze(Ca(:, yy, xx));
                                    starts = [];
                                    ends = [];
                                    
                                    %                  trend = smooth( signal , 100 / tx , 'rlowess' ) ;
                                    %                   signal_m =  signal - trend ;
                                    %                   thr = par.Nthr * median( abs( signal_m - median(signal_m)) )/ 0.6745 + median(signal_m);
                                    %                    thr_abs = thr +median(signal_m);
                                    if par.type == 1
                                        xaux = find(Casignal >= Ca_thr(yy, xx));
                                        
                                        last_end = 0;
                                        xaux0 = 0;
                                        for f = 1:length(xaux)
                                            if xaux(f) > last_end
                                                x_start = xaux(f);
                                                x_end = xaux(f);
                                                ff = f;
                                                while ff + 1 < length(xaux) && xaux(ff + 1) - xaux(ff) == 1
                                                    ff = ff + 1;
                                                    x_end = x_end + 1;
                                                end
                                                last_end = x_end;
                                                %                             x_max = x_start + iaux -1 ;
                                                starts = [starts, x_start - 1];
                                                ends = [ends, x_end];
                                                %                             maxs= [maxs x_max ];
                                            end
                                        end
                                        
                                        % Erase small duration events - they're noise
                                        durs = ends - starts + 1;
                                        bad_events = find(durs < Event_min_duration);
                                        starts(bad_events) = [];
                                        ends(bad_events) = [];
                                        starts(starts == 0) = 2;
                                        starts(starts == 1) = 2;
                                        
                                        Casignal(xaux) = NaN;
                                        if isnan(Casignal(1:5))
                                            %                       f  =   signal( signal  )  ;
                                            f = find(~isnan(Casignal), 1);
                                            if ~isempty(f)
                                                s1 = Casignal(f(1));
                                                Casignal(1:f) = s1;
                                            end
                                        end
                                        Casignal(Casignal < 0) = 0;
                                        
                                        Ca_F0(:, yy, xx) = smooth(Casignal, Smooth_window, 'moving')';
                                        dff = 100 * (squeeze(Ca(:, yy, xx)) - Ca_F0(:, yy, xx)) ...
                                            ./ Ca_F0(:, yy, xx);
                                        dff(dff > dF_F0_limit) = 0;
                                        Ca(:, yy, xx) = dff;
                                        
                                        estart{yy, xx} = starts;
                                        eend{yy, xx} = ends;
                                        events_num(yy, xx) = length(ends);
                                    end
                                    
                                    if par.type == 2
                                        
                                        if Ca_thr(yy, xx) > 0
                                            Casignal = squeeze(Ca(:, yy, xx));
                                            smooth1 = smooth(Casignal, Smooth_window_prime, 'sgolay')';
                                            smooth1_m = Casignal - smooth1';
                                            
                                            Ca_mean0 = median(smooth1_m);
                                            Ca_no_mean = smooth1_m - Ca_mean0;
                                            % Threshold detection
                                            Ca_thr1 = par.Nthr * median(abs(Ca_no_mean)) / 0.6745 + Ca_mean0;
                                            xaux = find(smooth1_m >= Ca_thr1);
                                            
                                            % find events each pixel
                                            last_end = 0;
                                            xaux0 = 0;
                                            for f = 1:length(xaux)
                                                if xaux(f) > last_end
                                                    x_start = xaux(f);
                                                    x_end = xaux(f);
                                                    ff = f;
                                                    while ff + 1 < length(xaux) && xaux(ff + 1) - xaux(ff) == 1
                                                        ff = ff + 1;
                                                        x_end = x_end + 1;
                                                    end
                                                    last_end = x_end;
                                                    %                             x_max = x_start + iaux -1 ;
                                                    starts = [starts, x_start - 1];
                                                    ends = [ends, x_end];
                                                    %                             maxs= [maxs x_max ];
                                                end
                                            end
                                            % Erase small duration events - they're noise
                                            durs = ends - starts + 1;
                                            bad_events = find(durs < Event_min_duration);
                                            starts(bad_events) = [];
                                            ends(bad_events) = [];
                                            starts(starts == 0) = 2;
                                            starts(starts == 1) = 2;
                                            
                                            estart{yy, xx} = starts;
                                            eend{yy, xx} = ends;
                                            events_num(yy, xx) = length(ends);
                                            %-------------
                                            
                                            % erase event data to find baseline between
                                            Casignal(xaux) = NaN;
                                            
                                            Ca_F0(:, yy, xx) = smooth(Casignal, Smooth_window, 'moving');
                                            
                                            dff = 100 * (squeeze(Ca(:, yy, xx)) - Ca_F0(:, yy, xx)) ...
                                                ./ Ca_F0(:, yy, xx);
                                            % "hamming" window of dFF
                                            Ht = 5;
                                            ham = (1:Ht);
                                            dff(ham) = dff(ham) .* (ham' / Ht); % [10 10 10...]->[0.1 0.3 0.5 .. 10 .. ]
                                            dff(end - Ht + ham) = dff(end - Ht + ham) .* ((Ht - ham' + 1) / Ht);
                                            
                                            if ~par.fast_analysis
                                                signal0 = squeeze(Ca(:, yy, xx));
                                            end
                                            
                                            if smooth_Ca_signals_dFF
                                                dff = smooth(dff, 3, 'moving');
                                            end
                                            
                                            dff(dff > dF_F0_limit) = 0; % if dF/F to high it's artifact
                                            Ca(:, yy, xx) = dff;
                                        else
                                            %                       Ca_F0( : , yy , xx  ) =  0 * signal;
                                            Ca(:, yy, xx) = 0 * Casignal;
                                        end
                                        
                                        if ~par.fast_analysis
                                            if yy == yyy && xx == xxx
                                                
                                                Ny = 4;
                                                Nx = 1;
                                                time = acq.time * (1:length(Casignal));
                                                figure
                                                h1 = subplot(Ny, Nx, 1);
                                                hold on
                                                plot(time, signal0)
                                                plot(time, smooth1, 'g')
                                                legend('F', 'F_s_m_o_o_t_h')
                                                ylabel('A.U.')
                                                xlabel('time, sec')
                                                h2 = subplot(Ny, Nx, 2);
                                                hold on
                                                plot(time, smooth1_m)
                                                plot([1, max(time)], [Ca_thr1, Ca_thr1], 'r')
                                                legend('F - F_s_m_o_o_t_h', 'Threshold_1')
                                                ylabel('A.U.')
                                                xlabel('time, sec')
                                                h3 = subplot(Ny, Nx, 3);
                                                hold on
                                                plot(time, signal0)
                                                plot(time, Casignal, 'r')
                                                plot(time, squeeze(Ca_F0(:, yy, xx)), 'm')
                                                %                                    plot(  time,  smooth(Casignal0 ,Smooth_window , 'moving' ));
                                                legend('F', 'F no events', 'F0');
                                                ylabel('A.U.')
                                                xlabel('time, sec')
                                                h4 = subplot(Ny, Nx, 4);
                                                plot(time, squeeze(Ca(:, yy, xx)), 'k')
                                                ylabel('dF/F_0')
                                                xlabel('time, sec')
                                                legend('dF/F_0')
                                                linkaxes([h1, h2, h3, h4], 'x')
                                                drawnow;
                                            end
                                        end
                                    end
                                    
                                end
                                
                                %%pfpm.increment(xx);
                            end
                        end
                        %         Ca( isnan( Ca )) = 0 ;
                        %         toc
                        
                        %-- Plot one pixel with marked events ------------
                        [v, ind] = max(events_num(:));
                        [y_max_e, x_max_e] = ind2sub(size(events_num), ind);
                        if ~show_selected_pixel_analysis
                            yyy = y_max_e;
                            xxx = x_max_e;
                        end
                        xx = xxx;
                        yy = yyy;
                        
                        if ~par.fast_analysis
                            if ~showed_figure
                                if exist('dbg', 'var')
                                    %                             figure ; hold on ;
                                    %                              plot( squeeze(  dbg(  yy  , xx  , : )) , 'r'  )
                                    %                              plot( squeeze(  Ca( : , yy  , xx   )  ))
                                    %                             legend( 'original signal' , 'filtered signal'  )
                                    
                                    figure;
                                    hold on;
                                    Nx = 1;
                                    Ny = 2;
                                    h1 = subplot(Ny, Nx, 1);
                                    hold on;
                                    tx = acq.time;
                                    plot(tx * (1:length(squeeze(dbg(yy, xx, :)))), ...
                                        squeeze(dbg(yy, xx, :)), 'r')
                                    Casignal = squeeze(dbg(yy, xx, :));
                                    signal2 = Casignal;
                                    xaux = find(Casignal > Ca_thr(yy, xx));
                                    Casignal(xaux) = NaN;
                                    title(['x =', num2str(xx), ' y=', num2str(yy)])
                                    %                             plot(tx * (1 : length(signal)) , signal , 'LineWidth' , 2  )
                                    %                             plot( [ 0 tx * length(signal)] ,  [ Ca_thr( yy  , xx   ) Ca_thr( yy  , xx   )  ] , 'g') ;
                                    Ca_F0_line = squeeze(Ca_F0(:, yy, xx));
                                    plot(tx * (1:length(Ca_F0_line)), Ca_F0_line, 'm', 'LineWidth', 2);
                                    plot(tx * estart{yy, xx}, signal2(estart{yy, xx}), '*r')
                                    plot(tx * eend{yy, xx}, signal2(eend{yy, xx}), '*g')
                                    legend('original signal', 'signal', 'Threshold', 'F0', 'starts', 'ends')
                                    legend('original signal', 'F0', 'starts', 'ends')
                                    f = 0;
                                    xlabel('time, sec')
                                    ylabel('Signal')
                                    showed_figure = true;
                                    h2 = subplot(Ny, Nx, 2);
                                    plot(tx * (1:length(Casignal)), squeeze(Ca(:, yy, xx)))
                                    ylabel('Df/F, %')
                                    xlabel('Time, sec')
                                    drawnow
                                end
                            end
                        end
                        %--------------------------------------
                        t1 = output('Event detection each pixel done', whos, toc(tStart), t1);
                        
                        %%  dF/F0 thresholds , find events dF/F0 ; Output : Ca Ca_events  Ca_F0 Ca_dFF
                        
                        t1 = output('Event detection dF/F0 each pixel started', whos, toc(tStart), t1);
                        %
                        %             %pfpm = ParforProgress2('varif(z,[0 0 win],''rectangular'')', N, 1, 0, 1);
                        
                        %-- dF/F0 get thresholds
                        %             s = size( Ca );
                        Ca_thr_dff = zeros(s(1), s(2));
                        for yy = 1:floor(sz(1))
                            for xx = 1:sz(2) %par
                                tile = Ca(:, yy, xx);
                                tile(isnan(tile)) = 0;
                                tile(~isfinite(tile)) = 0;
                                Ca(:, yy, xx) = tile;
                                Ca_mean0 = median(squeeze(Ca(:, yy, xx)));
                                Ca_no_mean = squeeze(Ca(:, yy, xx)) - Ca_mean0;
                                % new
                                sigma = median(abs(Ca_no_mean)) / 0.6745;
                                if sigma > Ca_mean0
                                    Ca_thr_dff(yy, xx) = par.Nthr_dFF * sigma + Ca_mean0;
                                else
                                    Ca_thr_dff(yy, xx) = 100 * Ca_mean0;
                                end
                            end
                        end
                        
                        %         matVis( Ca ) ;
                        %                 z_dff_mean0 =  ( (median( Ca , 1 )) ) ;
                        %                 Ca_no_mean = Ca ;
                        %                 Ca_thr_dff = zeros( s(1),s(2));
                        %                 sz2 = size(Ca);
                        %                 for ti=1:sz2(1)
                        %                     Ca_no_mean( ti, :,:) = Ca(ti, :,:)  - z_dff_mean0  ;
                        %                 end
                        %                 Ca_thr_dff  = par.Nthr_dFF * median( abs(Ca_no_mean) , 1)/ 0.6745 +  z_dff_mean0   ;
                        %                 Ca_thr_dff = squeeze( Ca_thr_dff );
                        %                  clear Ca_no_mean
                        
                        %                  figure; imagesc( Ca_thr_dff ) ;colorbar ;
                        %------------------------------------
                        
                        dff_estart = cell(sz(1), sz(2));
                        dff_eend = cell(sz(1), sz(2));
                        dff_emax = cell(sz(1), sz(2));
                        dff_events_num = zeros(sz(1), sz(2));
                        Ca_dFF = Ca;
                        if ~par.fast_analysis
                            Ca_dFF = Ca;
                            
                        end
                        
                        %        Ca_events = Ca ;
                        dd = whos('Ca');
                        [~, sys] = memory;
                        dnn = min([xs, floor(xs * sys.PhysicalMemory.Available / dd.bytes / 22)]);
                        
                        %%pfpm = ParforProgress2('varif(z,[0 0 win],''rectangular'')', N, 1, 0, 1);
                        dnn = parfor_d;
                        
                        for sxx = 1:dnn:xs %parfor
                            dnn = min([dnn, xs - sxx + 1]);
                            nsub = sxx - 1 + (1:dnn);
                            parfor xx = nsub %parfor
                                
                                for yy = 1:ys
                                    Casignal = squeeze(Ca(:, yy, xx));
                                    starts = [];
                                    ends = [];
                                    xaux = find(Casignal > Ca_thr_dff(yy, xx));
                                    
                                    % erase silent data
                                    %                  signal( xaux ) = NaN ;
                                    
                                    if yy == yyy && xx == xxx
                                        a = 0;
                                    end
                                    
                                    last_end = 0;
                                    xaux0 = 0;
                                    for f = 1:length(xaux)
                                        if xaux(f) > last_end
                                            x_start = xaux(f);
                                            x_end = xaux(f);
                                            ff = f;
                                            %                             while ~isnan( signal( x_end ) ) && x_end  < sz_stack(3)
                                            while ff < length(xaux) && xaux(ff + 1) - xaux(ff) == 1
                                                ff = ff + 1;
                                                x_end = x_end + 1;
                                            end
                                            
                                            if x_end < sz_stack(3)
                                                x_end = x_end + 1;
                                            end
                                            last_end = x_end;
                                            Amax = max(Casignal(x_start:x_end));
                                            As_e = 0.5 * (Casignal(x_start) + Casignal(x_end));
                                            
                                            % if Max Ca in event higher then at start;end
                                            % then its "event"
                                            if 100 * (Amax - As_e) / As_e > par.Nthr_dFF_max_min
                                                starts = [starts, x_start - 1];
                                                ends = [ends, x_end];
                                            end
                                        end
                                    end
                                    
                                    % Erase small duration events - they're noise
                                    durs = ends - starts - 1;
                                    bad_events = find(durs < Event_min_duration);
                                    starts(bad_events) = [];
                                    ends(bad_events) = [];
                                    starts(starts == 0) = 2;
                                    starts(starts == 1) = 2;
                                    
                                    no_events_dots = 1:sz_stack(3);
                                    for e = 1:length(ends)
                                        if e <= length(ends)
                                            no_events_dots(starts(e) - 1:ends(e) + 1) = 0;
                                        else
                                            no_events_dots(starts(e) - 1:ends(e)) = 0;
                                        end
                                    end
                                    no_events_dots(no_events_dots == 0) = [];
                                    
                                    if par.erase_no_events_Ca
                                        Casignal(no_events_dots) = 0;
                                    end
                                    Casignal(Casignal < dff_abs_thres) = 0;
                                    
                                    Ca(:, yy, xx) = Casignal;
                                    
                                    %                  signal_events = squeeze(  Ca_dFF( : , yy  , xx   ) );
                                    %                  signal_events( signal_events < Ca_thr_dff( yy  , xx   ) ) = 0 ;
                                    %                  signal_events( signal_events < dff_abs_thres ) = 0 ;
                                    %                  Ca_dFF_events( : , yy  , xx   ) = signal_events ;
                                    
                                    if ~par.fast_analysis
                                        %                  Ca_idx = find( signal == 0 );
                                        %                  Ca_signal_events = squeeze(  Ca( : , yy  , xx   ) );
                                        %                  Ca_signal_events( Ca_idx ) = 0 ;
                                        %                  Ca( : , yy  , xx   ) = Ca_signal_events ;
                                    end
                                    dff_estart{yy, xx} = starts;
                                    dff_eend{yy, xx} = ends;
                                    dff_events_num(yy, xx) = length(ends);
                                end
                                
                                %             %pfpm.incremen(yy);
                            end
                        end
                        
                        if ~par.fast_analysis
                            show_signal_from_original_dFF = true;
                            figure;
                            hold on;
                            Nx = 1;
                            Ny = 2;
                            yy = yyy;
                            xx = xxx;
                            tx = acq.time;
                            
                            if show_signal_from_original_dFF
                                Casignal = squeeze(Ca_dFF(:, yy, xx));
                            else
                                Casignal = squeeze(Ca(:, yy, xx));
                            end
                            
                            plot(tx * (1:length(Casignal)), Casignal, 'r')
                            starts = Casignal(dff_estart{yy, xx});
                            ends = Casignal(dff_eend{yy, xx});
                            xaux = find(Casignal > Ca_thr_dff(yy, xx));
                            Casignal(xaux) = NaN;
                            plot(tx * (1:length(Casignal)), Casignal, 'LineWidth', 2)
                            plot([0, tx * length(Casignal)], [Ca_thr_dff(yy, xx), Ca_thr_dff(yy, xx)], 'g');
                            plot(tx * dff_estart{yy, xx}, starts, '*r')
                            plot(tx * dff_eend{yy, xx}, ends, '*g')
                            xlabel('Time, s')
                            ylabel('dF/F0, %')
                            legend('original signal', 'signal', 'Threshold', 'starts', 'ends', 'F0')
                        end
                        %           profile viewer
                        
                        t1 = output('Event detection dF/F0 each pixel done', whos, toc(tStart), t1);
                        
                        Ca = shiftdim(Ca, 1);
                        %         Ca_events = shiftdim( Ca_events , 1 ) ; % Ca dF/F0 events - dF/F0 only in events
                        Ca_F0 = shiftdim(Ca_F0, 1);
                        
                        %         Ca_dFF = shiftdim(  Ca_dFF , 1 ) ;
                        %          Ca_dFF_events = shiftdim(  Ca_dFF_events , 1 ) ;
                        
                        %           matVis( Ca_dFF   );
                        %           matVis( Ca_events   );
                        %         stopHere ;
                        %           save temp_ca.mat
                        
                        %% UNN - Detect events and filter small - each frame
                        % filter small events in each frame separately (small pixels)
                        % input : Ca_events Ca_dFF estart{ yy , xx } eend{ yy , xx }
                        % out : Ca_Bif - binary events ; Caf - dF/F0 events ; Ca_abs_events
                        % - Ca events
                        start_events_detection = tic;
                        % save( sprintf ('%s\\Ca.mat', path_save) , 'Ca' );
                        Ca_Bif = Ca;
                        Caf = Ca;
                        if ~par.fast_analysis
                            Ca_abs_events = Ca;
                        else
                            if ~par.MakingLoop
                                %clear Ca
                                %clear Ca_F0
                            end
                        end
                        
                        t1 = output('Detect events and filter small each frame', whos, toc(tStart), t1);
                        %         tic
                        for ti = 1:floor(sz_stack(3) * 1) % parfor
                            %                      if ~par.fast_analysis
                            %                         slice = Ca( : , : , ti );
                            %                      end
                            events_idx_binar = Caf(:, :, ti) > 0;
                            events_idx_binar = imfill(events_idx_binar, 'holes');
                            Event_slice = Caf(:, :, ti);
                            
                            areas = regionprops(events_idx_binar, 'Area', 'PixelIdxList');
                            for si = 1:length(areas)
                                if areas(si).Area < Event_min_Size
                                    %                             if ~par.fast_analysis
                                    %                                 slice(  areas( si ).PixelIdxList ) = 0 ;
                                    %                             end
                                    %                    pl = areas( si ).PixelList ;
                                    events_idx_binar(areas(si).PixelIdxList) = 0;
                                end
                            end
                            Event_slice(~events_idx_binar) = 0;
                            
                            Ca_Bif(:, :, ti) = events_idx_binar;
                            Caf(:, :, ti) = Event_slice;
                            %                     if ~par.fast_analysis
                            %                         slice( ~events_idx_binar ) =0 ;
                            %                         Ca_abs_events( : , : , ti ) = slice ;
                            %                     end
                            
                        end
                        if ~par.MakingLoop
                            %clear Ca
                        end
                        
                        t1 = output('Detect events and filter small each frame finished', whos, toc(tStart), t1);
                        
                        %           events_idx_binar = Ca_Bif  > 0 ;
                        %           events_idx_binar = imfill(events_idx_binar,'holes');
                        %           Ca_Bif  = events_idx_binar ;
                        
                        %%
                        if ~par.UNN_events_detection
                            
                            %% Treshold Parameters
                            setThresholdParameters;
                            %thNA = 5; % line67ff: 'BG+5'
                            %thNA2 = 3; % BG+3;
                            %thNA3 = .5; % Ca_Bif(Caf > thNA3)=1;
                            if par.application
                                z = z_save(:, :, res(fn).ap_times_frame(naps, 1):res(fn).ap_times_frame(naps, 2));
                                xt = xt_save(res(fn).ap_times_frame(naps, 1):res(fn).ap_times_frame(naps, 2));
                                sz = size(z);
                            end
                            if naps == Naps
                                clear z_save xt_save
                            end
                            
                            %% Remove events (1)
                            t1 = output('ALPHA - Remove events (1): start', whos, toc(tStart), t1);
                            win = 100;
                            F0_std = zeros(sz, 'single');
                            N = sz(2);
                            %%pfpm = ParforProgress2('varif(z,[0 0 win],''rectangular'')', N, 1, 0, 1);
                            parfor nn = 1:N %par
                                F0_std(:, nn, :) = single(sqrt(varif(z(:, nn, :), [0, 0, win], 'rectangular'))); %buildstd(z,win);
                                %%pfpm.increment(i);
                            end
                            %%pfpm.delete();
                            t1 = output(sprintf('ALPHA - Remove events (1): varif(z,[0 0 %d],''rectangular'') done', win), whos, toc(tStart), t1);
                            S2 = minRegre1(F0_std, 2);
                            clear F0_std
                            t1 = output('ALPHA - Remove events (1): minRegre1(F0_std,2) done', whos, toc(tStart), t1);
                            zMean = z;
                            for win = 100:200:500
                                %F0_mean = buildmean1(zMean,win);
                                %t1 = output(sprintf('buildmean(zMean,%d) done',win), whos, toc(tStart), t1);
                                F0_mean = single(unif(z, [0, 0, win], 'rectangular'));
                                t1 = output(sprintf('ALPHA - Remove events (1): unif(z,[0 0 %d],''rectangular'') done', win), whos, toc(tStart), t1);
                                zMean(z > F0_mean + S2) = F0_mean(z > F0_mean + S2);
                            end
                            clear S2
                            t1 = output('ALPHA - Remove events (1): done', whos, toc(tStart), t1);
                            
                            %% Remove liner train
                            t1 = output('ALPHA - Remove liner train: start', whos, toc(tStart), t1);
                            z1 = SGtime1(zMean, 3, 500, t1, tStart);
                            t1 = output('ALPHA - Remove liner train: SGtime1(zMean,3,500) done', whos, toc(tStart), t1);
                            z2 = z - z1 + repmat(mean(z, 3), [1, 1, sz(end)]);
                            clear z1
                            t1 = output('ALPHA - Remove liner train: Remove liner train done', whos, toc(tStart), t1);
                            
                            %% Remove events (2)
                            t1 = output('ALPHA - Remove events (2) start', whos, toc(tStart), t1);
                            win = 100;
                            N = sz(2);
                            F0_std = zeros(sz, 'single');
                            %%pfpm = ParforProgress2('varif(z2,[0 0 win],''rectangular'')', N, 1, 0, 1);
                            parfor nn = 1:N %par
                                F0_std(:, nn, :) = single(sqrt(varif(z2(:, nn, :), [0, 0, win], 'rectangular'))); %buildstd(z,win);
                                %%pfpm.increment(i);
                            end
                            %%pfpm.delete();
                            t1 = output(sprintf('ALPHA - Remove events (2): varif(z2,[0 0 %d],''rectangular'') done', win), whos, toc(tStart), t1);
                            S2 = minRegre1(F0_std, 2);
                            t1 = output(sprintf('ALPHA - Remove events (2): minRegre1(F0_std,2) done', win), whos, toc(tStart), t1);
                            Out = false(size(z2));
                            for win = 100:200:500
                                F0_mean_2 = single(unif(z2, [0, 0, win], 'rectangular'));
                                t1 = output(sprintf('ALPHA - Remove events (2): unif(z2,[0 0 %d],''rectangular'') done', win), whos, toc(tStart), t1);
                                Out(z2 > F0_mean_2 + S2) = 1;
                            end
                            zMean(Out(:)) = F0_mean(Out(:));
                            clear F0_mean F0_mean_2 z2
                            t1 = output(sprintf('ALPHA - Remove events (2): zMean(Out(:))= F0_mean(Out(:))'), whos, toc(tStart), t1);
                            % matVis(z,F0_mean,F0_std,S2,zMean)
                            % figure,plot(ts,squeeze(zMean(px{:})),ts,squeeze(z1(px{:})));hl=legend('zMean','z1');set(hl,'Location','best','Interpreter','none');
                            t1 = output('ALPHA - Remove events (2):  win loop done', whos, toc(tStart), t1);
                            
                            %% median from 0.1 to 0.5 percentile
                            t1 = output('ALPHA - Remove events (2):  median from 0.1 to 0.5 percentile', whos, toc(tStart), t1);
                            F0_median = buildmedian1(z, 250, 0.1, 0.5);
                            t1 = output(sprintf('ALPHA - Remove events (2):  buildmedian1(z,250,0.1,0.5) done'), whos, toc(tStart), t1);
                            win = 100;
                            Out(F0_std >= S2 * 0.75) = 1;
                            zMean(F0_std >= S2 * 0.75) = F0_median(F0_std >= S2 * 0.75);
                            t1 = output(sprintf('ALPHA - Remove events (2):  zMean updated'), whos, toc(tStart), t1);
                            z1a = SGtime1(zMean, 3, win, t1, tStart);
                            t1 = output(sprintf('ALPHA - Remove events (2):  SGtime1(zMean,3,%d) done', win), whos, toc(tStart), t1);
                            clear zMean
                            clear F0_mean F0_median F0_std S2
                            
                            t1 = output(sprintf('ALPHA - Remove events (2):  done', win), whos, toc(tStart), t1);
                            
                            %% noise analysis
                            t1 = output(sprintf('ALPHA: start noise analysis (!!!fake after gauss blur!!!)'), whos, toc(tStart), t1);
                            %Va = BL_Var(z,z1a,Out);
                            Va = single(var(dip_image(z - z1a), ~Out, 3));
                            Av = mean(z1a, 3);
                            X = 0:1:max(Av(:));
                            k1 = polyfit(Av(Av < 5), Va(Av < 5), 1);
                            k2 = polyfit(Av(Av >= 5), Va(Av >= 5), 1);
                            T = double((max(polyval(k1, X), polyval(k2, X))));
                            kk = polyfit(X, T, 10);
                            T = polyval(kk, X);
                            %k = Av(Av>=BG+thNA); k(:,2) = 1; k = flipdim(k\Va(Av>=BG+thNA),1);
                            clear Out
                            t1 = output(sprintf('ALPHA: slope: % 5.2f   Offset:  % 5.2f', k2(1), k2(2)), whos, toc(tStart), t1);
                            
                            %% noise analysis contour plot
                            t1 = output(sprintf('ALPHA: prepare noise analysis contour plot'), whos, toc(tStart), t1);
                            % foreground and background color of the figures
                            if 0, cf = 'w';
                                cb = 'k'; % ForeGround: 'w', BackGround: 'k'
                            else cf = 'k';
                                cb = 'w'; % ForeGround: 'k', BackGround: 'w'
                            end
                            h2dx = linspace(0, max(Av(:)), 100);
                            h2dy = linspace(0, max(Va(:)), 100);
                            h2d = hist2wf([Av(:), Va(:)], h2dx, h2dy);
                            h2d(h2d <= 0) = .1;
                            h2d = log10(h2d);
                            fig = figure('Position', [100, 100, 450, 400], 'Color', cb, 'Visible', 'on');
                            sub1 = subplot('Position', [.11, .11, .6, .78], 'Color', cb, 'XColor', cf, 'YColor', cf);
                            hold all
                            contour(sub1, h2dx, h2dy, h2d', 'LevelList', linspace(-1, max(h2d(:)), 32), 'LineStyle', '-', 'LineWidth', .5) %, 'Fill','on', 'LineStyle','none'
                            colormap(color_map(256, 2))
                            set(gca, 'XColor', cf, 'YColor', cf);
                            xlabel('mean intensity', 'Color', cf);
                            ylabel('intensity variance', 'Color', cf);
                            plot(sub1, X, T, 'k-', 'LineWidth', 1.5);
                            plot(sub1, X, thT^2 * T, 'k-', 'LineWidth', .75);
                            box on
                            title(sub1, {'Noise analysis', sprintf('var = %5.3f x mean + %5.3f', k2(1), k2(2))}, 'Color', cf, 'Interpreter', 'none'); %
                            h = colorbar('Position', [.75, .1, .05, .7]);
                            set(h, 'YTickLabel', num2str(10.^get(h, 'YTick')', '% 10.2f'));
                            set(h, 'XColor', cf, 'YColor', cf, 'XTick', []);
                            set(get(h, 'YLabel'), 'String', 'Frequency', 'Color', cf);
                            drawnow;
                            if par.saveFig
                                chstr = sprintf('results/images/%03d_%02d_noise_analysis_contour_plot', fn, naps);
                                export_fig(sprintf('%s.png', chstr), '-q100', '-nocrop', '-r300', fig);
                                close(fig);
                                drawnow;
                            end
                            clear X F_Va h2d * sub1 h Av Va
                            t1 = output(sprintf('ALPHA: noise analysis contour plot saved'), whos, toc(tStart), t1);
                            
                            %% Get dF/F of calcium response
                            t1 = output(sprintf('ALPHA: calculate dF/F calcium response'), whos, toc(tStart), t1);
                            dF = z - z1a;
                            F0 = z1a - BG;
                            F0m = mean(F0, 3);
                            [~, thNA2] = threshold(F0m, 'background', Inf);
                            fprintf('\n')
                            t1 = output(sprintf('ALPHA: F0 calculated, threshold for F0 = %4.2f', thNA2), whos, toc(tStart), t1);
                            fprintf('\n')
                            clear z z1a
                            Ca = dF ./ F0;
                            Cam = max(Ca, [], 3);
                            Cas = sum(Ca, 3);
                            Ca(F0 < thNA2) = 0; %BG+1
                            F0(F0 < 0) = 0;
                            t1 = output(sprintf('ALPHA: dF/F calcium response calculation done'), whos, toc(tStart), t1);
                            %ratio_image_adjust(truncate(Ca,-.2,2,1),(F0/max(F0(:))).^.5, 'rLim', [0 .5], 'iLim', [.02 .8])
                            %ratio_image_adjust(truncate(Ar,-.2,2,1),(F0/max(F0(:))).^.5, 'rLim', [0 .5], 'iLim', [.02 .8])
                            % ratio_image_adjust(truncate(Ca(:,:,1000:2000),-.2,10,1),(F0(:,:,1000:2000)/max(F0(:))).^.5, 'rLim', [0 .5], 'iLim', [.02 .8],'movieFps',18,'colorBar','\DeltaF/F_0')
                            
                            %% Event detection (1)
                            % Adjust baseline level
                            t1 = output(sprintf('ALPHA - Event detection (2): start baseline level adjustment'), whos, toc(tStart), t1);
                            % background image
                            CB = zeros([prod(sz(1:2)), 1], 'single');
                            % reshape Ca and F0
                            Ca = reshape(Ca, [prod(sz(1:2)), sz(3)]);
                            F0 = reshape(F0, [prod(sz(1:2)), sz(3)]);
                            t1 = output(sprintf('ALPHA - Event detection (2): calc index of pixels above threshold'), whos, toc(tStart), t1);
                            % index of pixels above threshold
                            ind = mean(F0, 2) >= thNA2 & mean(Ca, 2) > 0;
                            Nind = 1:length(ind);
                            Nind = Nind(ind);
                            Ca_pf = Ca(Nind, :);
                            t1 = output(sprintf('ALPHA - Event detection (2): prepare for background peak fit'), whos, toc(tStart), t1);
                            CBi = zeros([N, 1], 'single');
                            [~, sys] = memory; % checking available memory
                            dd = whos('Ca_pf'); % checking variable memory consumtion
                            if sys.PhysicalMemory.Available < dd.bytes * 2
                                % not enough memory for global (one step) calculation
                                % calc sequential mode
                                dnn = min([sz(2), floor(sz(2) * sys.PhysicalMemory.Available / (dd.bytes * 2) / 2)]);
                                nnCounter = 1;
                                nnCmax = ceil(sz(2) / dnn);
                                dnn = ceil(sz(2) / nnCmax);
                                t1 = output(sprintf('ALPHA - Event detection (2): peakfit_yw: start sequential calculation using %d loops (dbg => %4.2f GB, %4.2f GB per loop) ', nnCmax, prod(sz) * 8 / 1024 / 1024 / 1024, prod([sz(1:3), dnn]) * 8 / 1024 / 1024 / 1024), whos, toc(tStart), t1);
                                t1t = t1;
                                for nn = 1:dnn:sz(2)
                                    dnn = min([dnn, sz(2) - nn + 1]);
                                    nsub = nn - 1 + (1:dnn);
                                    %%pfpm = ParforProgress2('Background histogram Peakfit ', nsub, 1, 0, 1);
                                    parfor I = 1:nsub %
                                        A = squeeze(Ca_pf(I, :));
                                        [y, x] = hist(A, -1:.005:1);
                                        x(201) = [];
                                        y(201) = [];
                                        B = peakfit_yw(double([x(2:end - 1)', y(2:end - 1)']));
                                        % if abs(B(2))>1
                                        %   stopHere
                                        % end
                                        CBi(I) = single(B(2));
                                        %%pfpm.increment(I);
                                    end
                                    %%pfpm.delete();
                                    t1 = output(sprintf('ALPHA - Event detection (2): peakfit_yw: loop %d (%4.2f GB) done', nnCounter, prod([sz(1:3), dnn]) * 8 / 1024 / 1024 / 1024), whos, toc(tStart), t1);
                                    nnCounter = nnCounter + 1;
                                end
                                t1 = output(sprintf('ALPHA - Event detection (2): peakfit_yw: sequential calculation done'), whos, toc(tStart), t1t);
                            else
                                t1 = output(sprintf('ALPHA - Event detection (2): peakfit_yw: start global baseline level fit'), whos, toc(tStart), t1);
                                N = length(Nind); %%pfpm = ParforProgress2('Background histogram Peakfit ', N, 1, 0, 1);
                                parfor I = 1:N %
                                    A = squeeze(Ca_pf(I, :));
                                    [y, x] = hist(A, -1:.005:1);
                                    x(201) = [];
                                    y(201) = [];
                                    B = peakfit(double([x(2:end - 1)', y(2:end - 1)']));
                                    % if abs(B(2))>1
                                    %   stopHere
                                    % end
                                    CBi(I) = single(B(2));
                                    %%pfpm.increment(I);
                                end
                                %%pfpm.delete();
                                t1 = output(sprintf('ALPHA - Event detection (2): peakfit_yw: global baseline level fit done'), whos, toc(tStart), t1);
                            end
                            CB(Nind) = CBi;
                            clear Ca_pf Nind ind CBi A B x y nsub dnn nn
                            Ca = Ca - repmat(CB, [1, sz(3)]);
                            clear CB
                            Ca = reshape(Ca, sz);
                            F0 = reshape(F0, sz);
                            t1 = output(sprintf('ALPHA - Event detection (2): baseline level calculated'), whos, toc(tStart), t1);
                            
                            %% Use noise variance of the original data for setting the threshold
                            t1 = output(sprintf('ALPHA - Event detection (1): Use noise variance of the original data for seting the threshold'), whos, toc(tStart), t1);
                            %T = (F0+BG)*k(2) + k(1);T(T<0)=0;T =  sqrt(T);
                            T = sqrt(polyval(kk, F0));
                            Ca_Bi = false(size(Ca)); % Ca_Bi: binary image sequence if calcium events
                            Ca_Bi(dF > thT * T) = 1; % changed threshold from 2*T to 1.5*T
                            Ca_Bi(F0 < thNA2) = 0; % changes from BG+3 to BG+1
                            clear T %dF
                            t1 = output(sprintf('ALPHA - Event detection (1): Noise variance threshold set to 1.5 x STD'), whos, toc(tStart), t1);
                            
                            %% gauss blur Ca_Bi and threshold + close holes
                            t1 = output(sprintf('ALPHA - Event detection (1): gauss blur Ca_Bi and threshold + close holes'), whos, toc(tStart), t1);
                            Ca_Bi = single(gaussf(Ca_Bi, [2, 2, 0]));
                            t1 = output(sprintf('ALPHA - Event detection (1): gaussf(Ca_Bi,[2 2 0]) calculated'), whos, toc(tStart), t1);
                            Ca_Bi(Ca_Bi >= 0.4) = 1;
                            Ca_Bi(Ca_Bi ~= 1) = 0;
                            Ca_Bi(F0 < thNA2) = 0;
                            t1 = output(sprintf('ALPHA - Event detection (1): start imfill(Ca_Bi,4,''holes'')'), whos, toc(tStart), t1);
                            N = sz(3);
                            %pfpm = ParforProgress2('imfill(Ca_Bi,4,''holes'')', N, 1, 0, 1);
                            parfor I = 1:N
                                Ca_Bi(:, :, I) = imfill(Ca_Bi(:, :, I), 4, 'holes'); %logical(fillholes(logical(Ca_Bi(:,:,i)),1));%
                                %pfpm.increment(I);
                            end
                            %pfpm.delete();
                            t1 = output(sprintf('ALPHA - Event detection (1): gauss blur Ca_Bi and threshold + close holes done'), whos, toc(tStart), t1);
                            
                            %% Event criteria: (integral > 0.3*20)
                            t1 = output(sprintf('ALPHA - Event detection (1): Start event criteria: (integral > 0.3*20)'), whos, toc(tStart), t1);
                            E2D = bwconncomp(logical(Ca_Bi), 4);
                            EvenPro = regionprops(E2D, Ca, 'MeanIntensity', 'Area');
                            for n = 1:size(EvenPro, 1)
                                if EvenPro(n).MeanIntensity * EvenPro(n).Area < 0.3 * 20 %0.3*20
                                    Ca_Bi(E2D.PixelIdxList{n}) = 0; % remove small intensity events
                                end
                            end
                            clear E2D EvenPro n
                            t1 = output(sprintf('ALPHA - Event detection (1): Event criteria: (integral > 20*0.3) done'), whos, toc(tStart), t1);
                            
                            %% Gaussian filtering
                            t1 = output(sprintf('ALPHA - Event detection (2): Start gaussian filtering'), whos, toc(tStart), t1);
                            Caf = single(gaussf(Ca, [1.5, 1.5, 1.5]));
                            F0f = single(gaussf(F0, [1.5, 1.5, 1.5]));
                            t1 = output(sprintf('ALPHA - Event detection (2): Gaussian filtering done'), whos, toc(tStart), t1);
                            
                            %% final? threshold
                            [~, thNAf2] = threshold(mean(F0f, 3), 'background', Inf);
                            fprintf('\n')
                            t1 = output(sprintf('ALPHA - Event detection (2): F0 calculated, threshold for F0 = %4.2f', thNA2), whos, toc(tStart), t1);
                            fprintf('\n')
                            Ca_Bif = false(size(Caf));
                            Ca_Bif(Caf > thNA3) = 1; % Yu-Wei used 0.1
                            Ca_Bif(F0f < thNAf2) = 0; % Ca_Bif(Caf.*F0f < 20) = 0; % Caf.*F0f is the absolute signal change deltaF
                            t1 = output(sprintf('ALPHA - Event detection (2): Binary mask of gaussfiltered data generated'), whos, toc(tStart), t1);
                            
                            %% compare events
                            t1 = output(sprintf('ALPHA - Event detection (2): bwconncomp(Ca_Bif,8) start'), whos, toc(tStart), t1);
                            % logical operation would somtimes delete parts of regions from a event
                            % Ca_Bi2 = Ca_Bi2 & Ca_Bi; % keep only events in Ca_Bi2 which are regions in Ca_Bi
                            E2Df = bwconncomp(Ca_Bif, 8);
                            t1 = output(sprintf('ALPHA - Event detection (2): bwconncomp(Ca_Bif,8) done'), whos, toc(tStart), t1);
                            
                            %% Remove events which not presented in "Event detection (1)"
                            % and recalculate event properties
                            t1 = output(sprintf('ALPHA - Event detection (2): regionprops(E2D2,Ca_Bi,''MaxIntensity'') start'), whos, toc(tStart), t1);
                            A2D = regionprops(E2Df, Ca_Bi, 'MaxIntensity');
                            t1 = output(sprintf('ALPHA - Event detection (2): regionprops(E2Df,Ca_Bi,''MaxIntensity'') done'), whos, toc(tStart), t1);
                            for n = 1:length(A2D)
                                if ~A2D(n).MaxIntensity
                                    Ca_Bif(E2Df.PixelIdxList{n}) = 0;
                                end
                            end
                            clear A2D
                            t1 = output(sprintf('ALPHA - Event detection (2): Remove events which not presented in "Event detection (1)"'), whos, toc(tStart), t1);
                            
                            %% fill holes of remaining regions
                            t1 = output(sprintf('ALPHA - Event detection (1): start imfill(Ca_Bif,4,''holes'')'), whos, toc(tStart), t1);
                            N = sz(3);
                            %pfpm = ParforProgress2('imfill(Ca_Bif,4,''holes'')', N, 1, 0, 1);
                            parfor I = 1:N
                                Ca_Bif(:, :, I) = imfill(Ca_Bif(:, :, I), 4, 'holes'); %logical(fillholes(logical(Ca_Bi(:,:,i)),1));%
                                %pfpm.increment(I);
                            end
                            %pfpm.delete();
                            t1 = output(sprintf('ALPHA - Event detection (1): gauss blur Ca_Bi and threshold + close holes done'), whos, toc(tStart), t1);
                        end
                        
                        %% UNN - final 3d filter : event integral , event duration minimum filter
                        t1 = output(sprintf('ALPHA - Event detection (2): Event criteria: (integral > 20*0.3) Start'), whos, toc(tStart), t1);
                        %If integral event pixel value is smaller than 3.5, it is removed from the event list
                        %           save( 'test01.mat')
                        
                        sz = size(Caf);
                        
                        E3D = bwconncomp(Ca_Bif, 26); % 3D
                        t1 = output(sprintf('ALPHA - Final event properties: bwconncomp(Ca_Bif,26) calc. for 3D'), whos, toc(tStart), t1);
                        EvenPro = regionprops(E3D, Caf, 'PixelValues', 'MeanIntensity', 'MaxIntensity', 'Area', 'PixelList', 'WeightedCentroid');
                        t1 = output(sprintf('ALPHA - Final event properties: regionprops(E3D) calc. for 3D'), whos, toc(tStart), t1);
                        % filter short events
                        t1 = output(sprintf('ALPHA - 3d filter: event integral , event duration minimum filter'), whos, toc(tStart), t1);
                        EventDurations = [];
                        
                        N_e = size(EvenPro, 1);
                        Area3D = []; % 'Area'
                        Cen2D = []; %uint16(round(MM(2:4,:)));  % 'WeightedCentroid'
                        Cen3D = [];
                        Mean3D = []; % 'MeanIntensity'
                        Peak3D = []; % 'MaxIntensity'
                        Integral = []; % Mean3D.*Area3D;
                        MM_pixval = []; % Sum of all dF/F points all frames all pixels
                        Events_start = [];
                        Events_end = [];
                        Events_data = [];
                        
                        for n = 1:size(EvenPro, 1)
                            delete_event = false;
                            % Event integral filter
                            if EvenPro(n).MeanIntensity * EvenPro(n).Area < Event_min_integral % small event
                                delete_event = true;
                            end
                            
                            wc = uint16(round(EvenPro(n).WeightedCentroid));
                            if wc(3) == 0 % artifact event
                                delete_event = true;
                            end
                            
                            Event_times = EvenPro(n).PixelList(:, 3);
                            Event_start = min(Event_times) * acq.time;
                            Event_end = (max(Event_times) + 1) * acq.time;
                            % bad event - erase it from Ca_Bif Caf
                            if Event_end - Event_start < Event_min_duration
                                delete_event = true;
                            end
                            
                            % extract event image stack
                            %             Event_times_fr = EvenPro(n).PixelList(:,3) ;
                            %             Event_start_fr = min( Event_times_fr );
                            %             Event_end_fr = max( Event_times_fr );
                            %             Event_duration_fr =  Event_end_fr - Event_start_fr ;
                            %
                            %             minx = min( EvenPro(n).PixelList(:,1)) ;
                            %             miny = min( EvenPro(n).PixelList(:,2)) ;
                            %             maxx = max( EvenPro(n).PixelList(:,1)) ;
                            %             maxy = max( EvenPro(n).PixelList(:,2)) ;
                            %
                            %             Event_img_stack = zeros( maxy - miny , maxx - minx , Event_duration_fr  );
                            %             Event_img_stack = Caf( miny : maxy , minx : maxx , Event_start_fr : Event_end_fr ) ;
                            %----------------------
                            
                            % matVis( Event_img_stack )
                            
                            if delete_event
                                Ca_Bif(E3D.PixelIdxList{n}) = 0; % remove small intensity events
                                Caf(E3D.PixelIdxList{n}) = 0; % remove small intensity events
                            else
                                EvenPro(n).Duration = Event_end - Event_start;
                                EventDurations = [EventDurations; Event_end - Event_start];
                                MM_pixval = [MM_pixval; sum(EvenPro(n).PixelValues)];
                                Area3D = [Area3D; EvenPro(n).Area];
                                Cen2D = [Cen2D; wc(1:2)]; % 'WeightedCentroid'
                                Cen3D = [Cen3D; wc]; % 'WeightedCentroid'
                                Mean3D = [Mean3D; EvenPro(n).MeanIntensity]; % 'MeanIntensity'
                                Peak3D = [Peak3D; EvenPro(n).MaxIntensity]; % 'MaxIntensity'
                                Events_start = [Events_start; Event_start];
                                Events_end = [Events_end; Event_end];
                                if par.save_Eventsinfo
                                    Events_data = [Events_data, EvenPro(n)];
                                end
                            end
                        end
                        
                        if par.extract_events
                            UNN_event_extract2
                            stopHere
                        end
                        
                        clear E3D
                        clear EvenPro
                        
                        Events.EventsNumber = numel(EventDurations);
                        Events.EventDurations = EventDurations;
                        Events.MM_pixval = MM_pixval;
                        Events.Area3D = Area3D;
                        Events.Cen2D = Cen2D;
                        Events.Mean3D = Mean3D; % 'MeanIntensity'
                        Events.Peak3D = Peak3D; % 'MaxIntensity'
                        Events.Events_start = Events_start;
                        Events.Events_end = Events_start;
                        Events.All_event_data = [EventDurations, MM_pixval, Area3D, Mean3D, Peak3D, Events_start, Events_start];
                        Events.Fieldnames_descriptions = {'Durations [sec]', 'Sum of dF/F pixels intensity', ...
                            'Number of pixels in 3d stack', 'Centroid in 2d image', 'Mean intensity of 3d event [%]', ...
                            'Max intensity of 3d event [%]', 'Event start [sec]', 'Event end [sec]'};
                        Events.Nthr = par.Nthr;
                        Events.F0_smooth_primal_sec = par.F0_smooth_primal_sec;
                        Events.F0_smooth_sec = par.F0_smooth_sec;
                        Events.Nthr_dFF = par.Nthr_dFF;
                        Events.file_name = '';
                        
                        Num_events = length(EventDurations);
                        clear EvenPro
                        
                        time_yu_wei_find_events = toc(start_events_detection);
                        
                        if par.save_Eventsinfo
                            
                            %save( sprintf('%s\\Events_info.mat', path_save), 'Events')
                            % return ;
                            E3D = bwconncomp(Ca_Bif, 26); % 3D
                            Events_3d = regionprops(E3D, Caf, 'Image', 'PixelValues', 'MeanIntensity', 'MaxIntensity', ...
                                'Area', 'PixelList', 'WeightedCentroid', 'SubarrayIdx');
                            Ca_dFF = shiftdim(Ca_dFF, 1);
                            % Export 3d event to txt
                            %             event_num_to_export = 1 ;
                            %             idx = Events_3d(event_num_to_export).SubarrayIdx ;
                            %             a = Caf( idx{1,1} , idx{1,2} , idx{1,3} ) ;
                            % Save_Image3d_txt
                            %             Output: 'event3d.txt'
                            
                            % Events_3d(i).Image_Ca3d - binary stack event 3d images
                            % Events_3d(i).Image - Ca dF/F stack event 3d images
                            
                            %             for i = 1 : numel( Events_3d )
                            %                 idx = Events_3d(i).SubarrayIdx ;
                            %                 a = Caf( idx{1,1} , idx{1,2} , idx{1,3} ) ;
                            %                 Events_3d(i).Image_Ca3d = a ;
                            %             end
                            
                            % matVis( Caf ) ;
                            
                            %save( 'Events_3d_stacks.mat' , 'Events' , 'Events_3d', '-v7.3');
                            %save( sprintf ('%s\\Ca_stacks.mat', path_save) , 'Caf' , 'Ca_Bif', '-v7.3');
                            %clear Events_3d E3D
                            %[f, s] = wavread('c:\windows\media\notify.wav');
                            %sound (f, s);
                            return;
                        end
                        
                        EventDurations = EventDurations;
                        mean_dur = median(EventDurations);
                        x = 0:mean_dur / 2:max(EventDurations);
                        [n, bin] = histc(EventDurations, x);
                        %           n = 100* n / sum(n);
                        %           figure
                        %             plot( x , n , 'Linewidth' , 2 );
                        %             xlabel( 'Duration, sec')
                        % %             ylabel( 'Probability, %')
                        %             ylabel( 'Number of events')
                        %             legend('Durations')
                        % filter artifact events
                        
                        %           t1 = output(sprintf('ALPHA - Final event properties: transfer output to individual Vectors'), whos, toc(tStart), t1);
                        %           MM = struct2cell(A3D);
                        %           MM = reshape([MM{:}],6,[]);
                        %           Area3D  = MM(1,:);    % 'Area'
                        %           Cen3D   = uint16(round(MM(2:4,:)));  % 'WeightedCentroid'
                        %           Mean3D  = MM(5,:);    % 'MeanIntensity'
                        %           Peak3D  = MM(6,:);    % 'MaxIntensity'
                        %           Integral = Mean3D.*Area3D;
                        %           MM_pixval = zeros(1,length(A3D_pixval) ); % Sum of all dF/F points all frames all pixels
                        
                        %           A3D_pixval = regionprops(E3D,Caf, 'PixelValues' );%,'Centroid','BoundingBox'
                        %           for mi = 1 : length(A3D_pixval)
                        %             MM_pixval(mi) = sum( A3D_pixval( mi ).PixelValues );
                        %           end
                        %
                        %           bad_events = find( Cen3D(3,:) == 0 ) ;
                        %           Cen3D( : , bad_events ) = [];
                        %           Area3D( bad_events ) = [];
                        %           Mean3D( bad_events ) = [];
                        %           Peak3D( bad_events ) = [];
                        %           MM_pixval( bad_events ) = [];
                        %
                        %           t1 = output(sprintf('ALPHA - Final event properties: transfer done'), whos, toc(tStart), t1);
                        t1 = output(sprintf('ALPHA - Final event properties: Measurement done'), whos, toc(tStart), t1);
                        
                        if par.save_stacks_Ca
                            save(sprintf('%s\\Ca_stacks.mat', path_save), 'Caf', 'Ca_Bif');
                        end
                        
                        if par.show_stack_matVi
                            matVis(Ca_Bif);
                            %         matVis( Caf ) ;
                            Events_number = length(EventDurations)
                            %           matVis( Ca_Bif ) ;
                            stopHere;
                        end
                        
                        %%  Event spatial statistics - activity skeletons
                        if par.Get_activity_skeleton
                            
                            Caf_nan = Caf;
                            for yy = 1:floor(sz(1))
                                for xx = 1:sz(2) %par
                                    trace = squeeze(Ca_Bif(yy, xx, :));
                                    dif = diff(trace);
                                    evnts = length(find(dif == 1));
                                    dff_events_num(yy, xx) = evnts;
                                    
                                    trace = squeeze(Caf(yy, xx, :));
                                    trace(trace == 0) = NaN;
                                    Caf_nan(yy, xx, :) = trace;
                                end
                            end
                            
                            size_s = size(Caf);
                            dim_t = find(size_s == timepoints_num);
                            %         Caf_mean = mean( Caf , dim_t ) ;
                            Caf_events_per_min = dff_events_num / acq.minutes_num;
                            Ca_active_time = (sum(Ca_Bif, dim_t) * acq.time) / 60;
                            Ca_active_number = (sum(Ca_Bif, dim_t));
                            Ca_active_time = (100 * Ca_active_time) / acq.minutes_num;
                            %         Caf_mean_only_events =  mean( Caf , dim_t ) ;
                            Caf_mean_total = mean(Caf, dim_t);
                            Caf_mean_only_events = nanmean(Caf_nan, dim_t);
                            %         Ca_sample_morph( Ca_sample_morph > max(max( Ca_sample_morph )) * 0.2 ) = 0 ;
                            dff_events_num(dff_events_num > 0) = 1;
                            
                            bins = 50;
                            tt = Caf_events_per_min(:)';
                            tt = tt(tt > 0);
                            [n, x] = hist(tt, bins);
                            n = 100 * n / length(tt);
                            hist_Caf_events_per_min.x = x;
                            hist_Caf_events_per_min.y = n;
                            
                            tt = Ca_active_time(:)';
                            tt = tt(tt > 0);
                            [n, x] = hist(tt, bins);
                            n = 100 * n / length(tt);
                            hist_Ca_active_time.x = x;
                            hist_Ca_active_time.y = n;
                            
                            tt = Caf_mean_total(:)';
                            tt = tt(tt > 0);
                            [n, x] = hist(tt, bins);
                            n = 100 * n / length(tt);
                            hist_Caf_mean_only_events.x = x;
                            hist_Caf_mean_only_events.y = n;
                            
                            Nx = 2;
                            Ny = 2;
                            figure;
                            h1 = subplot(Ny, Nx, 1);
                            imagesc(Caf_mean);
                            colorbar;
                            axis square;
                            title('Mean fluorescence')
                            %         h2 = subplot( Ny,Nx,2) ;
                            %             imagesc( Caf_mean_total ); colorbar; axis square ;
                            %             title( 'Mean activity, % dF/F0')
                            h3 = subplot(Ny, Nx, 2);
                            imagesc(Caf_events_per_min);
                            colorbar;
                            axis square;
                            title('Event frequency, event/min')
                            h4 = subplot(Ny, Nx, 3);
                            imagesc(Ca_active_time);
                            colorbar;
                            axis square;
                            title('Active time, %')
                            %         linkaxes( [ h1 h2 h3 h4 ], 'xy' )
                            linkaxes([h1, h3, h4], 'xy')
                            
                            figure;
                            h1 = subplot(Ny, Nx, 1);
                            imagesc(dff_events_num);
                            colorbar;
                            axis square;
                            title('Events active parts')
                            h2 = subplot(Ny, Nx, 2);
                            bar(hist_Caf_mean_only_events.x, hist_Caf_mean_only_events.y);
                            xlabel('Events number')
                            ylabel('%')
                            title('Mean activity, % dF/F0')
                            h3 = subplot(Ny, Nx, 3);
                            bar(hist_Caf_events_per_min.x, hist_Caf_events_per_min.y);
                            xlabel('Events number')
                            ylabel('%')
                            title('Event frequency')
                            h4 = subplot(Ny, Nx, 4);
                            bar(hist_Ca_active_time.x, hist_Ca_active_time.y);
                            xlabel('Events number')
                            ylabel('%')
                            title('Active time, %')
                            %           stopHere ;
                            
                        end
                        
                        if par.additional_processing
                            t1 = output(sprintf('ALPHA - 3d filter: event integral , event duration minimum filter done'), whos, toc(tStart), t1);
                            
                            %% Show the selected events
                            t1 = output(sprintf('ALPHA - Event detection (2): %% Show the selected events'), whos, toc(tStart), t1);
                            %{
            Ca_Bi_1 = Caf;
            Ca_Bi_1(Ca_Bif==1)=1;
            Ca_Bi_2 = zeros(size(Caf),'single');
            Ca_Bi_2(Ca_Bif==1) = Caf(Ca_Bif==1);
            twimshow1({Caf,Ca_Bi_1,Ca_Bif,Ca_Bi,Ca_Bi_2},{[0 0.8],[0 0.8],[0 0.8],[0 0.8],[0 0.8]}), colormap jet;
            clear Ca_Bi_1 Ca_Bi_2
                            %}
                            t1 = output(sprintf('ALPHA - Event detection (2) done: %% Show the selected events'), whos, toc(tStart), t1);
                            
                            %% save data for Sholl analysis
                            Ca_Bifm = sum(single(Ca_Bif), 3); % No of timepoints in event
                            Ca_Bifn = sum(single(Ca_Bif & ~circshift(Ca_Bif, [0, 0, 1])), 3); % egde recognition
                            
                            chstr = sprintf('results/data/%03d_%02d_F0mean.mat', fn, naps);
                            t1 = output(sprintf('ALPHA: save mean values as %s', chstr), whos, toc(tStart), t1);
                            %           save(chstr,'F0m','Cam','Cas','Ca_Bifm','Ca_Bifn')
                            t1 = output(sprintf('ALPHA:  mean values saved'), whos, toc(tStart), t1);
                            
                            %% PLOT istantaneous frequency
                            %           t1 = output(sprintf('ALPHA - Final event properties: PLOT istantaneous frequency start'), whos, toc(tStart), t1);
                            %
                            %           Cen3DT = single(sort(Cen3D(3,:)));                % z-coordinate -> time
                            %
                            %           %Inteval = (Cen3DT(2:end) - Cen3DT(1:end-1))*0.5;  % Yu-Wei
                            %           Inteval = 60 * (xt(Cen3DT(2:end)) - xt(Cen3DT(1:end-1)));   % using time vector in Seconds
                            %           Inteval(Inteval==0) = 60*(xt(end)-xt(1))/(length(xt)-1)/2;  % 'one frame events' are set to half frame time
                            %           InstFre = 1./Inteval;
                            %           t = xt; %0:0.5:(sz(end)-1)*0.5;
                            %           x = zeros(size(t));
                            %           x(Cen3DT(2:end)) =InstFre;
                            %           clear InstFre Inteval
                            %           % prepar figure
                            %           fig = figure('Color', cb,'Visible','on');
                            %           plot(t, x);
                            %           xlabel('time / min');ylabel('Frequency');
                            %           title({'Event Frequency (1 / Event Interval)';'?I do not understand what this is good for?'});box on
                            %           drawnow;
                            %           if par.saveFig
                            %             chstr = sprintf('results/images/%03d_%02d_istantaneous_Ca2-frequency_plot',fn,naps);
                            %             export_fig(sprintf('%s.png',chstr),'-q100','-nocrop',fig);
                            %             close(fig);drawnow;
                            %           end
                            %           InstFre = cat(2, t', x');
                            %           clear t x
                            %           t1 = output(sprintf('ALPHA - Final event properties: PLOT istantaneous frequency done'), whos, toc(tStart), t1);
                            
                            %           %% Plot Binned Frequency every 10 sec
                            %
                            %
                            %           t1 = output(sprintf('ALPHA - Final event properties: Plot Binned Frequency every 10 sec start'), whos, toc(tStart), t1);
                            %           t = xt(1:10:sz(end));
                            %           BinFre = zeros(length(t),2);
                            %           BinFre(:,1)=t/2;
                            %           NN = length(Cen3DT);
                            %           for j = 1:length(t)
                            %             BinFre(j,2) = sum(Cen3DT >= 10*(j-1) & Cen3DT <= 10*j);
                            %             %  for i = 1:length(Cen3DT)
                            %             %     if Cen3DT(i) >= 10*(j-1) && Cen3DT(i) <= 10*j
                            %             %        BinFre(j,2)=BinFre(j,2)+1;
                            %             %     end
                            %             %  end
                            %           end
                            %           BinFre(:,2) = BinFre(:,2)/10.*60;
                            %           t1 = output(sprintf('ALPHA - Final event properties: Binned Frequency calculated'), whos, toc(tStart), t1);
                            %           % prepare figure
                            %           fig = figure('Color', cb,'Visible','on');
                            %           bar(BinFre(:,1), BinFre(:,2),'DisplayName','BinFre','YDataSource','BinFre');%figure(gcf)
                            %           xlim([min(t) max(t)]/2);
                            %           xlabel('time / min');ylabel('Frequency');
                            %           title({'Binned Frequency every 10 sec'});box on
                            %           drawnow;
                            %           if par.saveFig
                            %             chstr = sprintf('results/images/%03d_%02d_binned_Ca2-frequency_plot',fn,naps);
                            %             export_fig(sprintf('%s.png',chstr),'-q100','-nocrop',fig);
                            %             close(fig);drawnow;
                            %           end
                            %           t1 = output(sprintf('ALPHA - Final event properties: Plot Binned Frequency every 10 sec done'), whos, toc(tStart), t1);
                            
                            %% Calculate duration and maximum projection area
                            E3D = bwconncomp(Ca_Bif, 26); % 3D
                            %           E3D.PixelIdxList = regionprops(E3D,Caf, 'PixelIdxList' );
                            
                            t1 = output(sprintf('ALPHA - Final event properties: Calculate duration and maximum projection area start'), whos, toc(tStart), t1);
                            sz = size(Caf);
                            xt = sz(3);
                            SamFre = 1 / acq.time; % (Hz)
                            N = length(E3D.PixelIdxList);
                            Dur = zeros(N, 1, 'double');
                            MaxArea = zeros(N, 1, 'double');
                            MaxProjArea = zeros(N, 1, 'double');
                            FirstArea = zeros(N, 1, 'double');
                            cent = [];
                            InitialFrames = false(sz(1), sz(2), N);
                            MaxFrames = false(sz(1), sz(2), N);
                            FinalFrames = false([sz(1:2), N]);
                            AllEvents = zeros([sz(1:3)], 'uint16');
                            szp12 = prod(sz(1:2));
                            %pfpm = ParforProgress2('Calc. duration and max proj. area', N, 1, 0, 1);
                            XX = (1:sz(1))';
                            YY = 1:sz(2);
                            %[xx,yy] = ndgrid(1:sz(1),1:sz(2));
                            for I = 1:N
                                [~, ~, z1] = ind2sub(sz, min(E3D.PixelIdxList{I}));
                                [~, ~, z2] = ind2sub(sz, max(E3D.PixelIdxList{I}));
                                NN = (z2 + 1 - z1);
                                Dur(I) = NN / SamFre;
                                % maximum projection area & initial projection area
                                G = false([sz(1:2), NN]);
                                G(E3D.PixelIdxList{I} - szp12 * (z1 - 1)) = true;
                                F = G(:, :, 1);
                                AllEvents(:, :, 1:NN) = AllEvents(:, :, 1:NN) + uint16(G);
                                MaxArea(I) = max(sum(sum(G)));
                                MaxProjArea(I) = sum(sum(max(G, [], 3)));
                                FirstArea(I) = sum(F(:));
                                InitialFrames(:, :, I) = F;
                                MaxFrames(:, :, I) = max(G, [], 3);
                                FinalFrames(:, :, I) = G(:, :, end);
                                G = single(G);
                                Gc = single(Caf(:, :, z1:z2));
                                %             Gf = single(Ca_F0(:,:,z1:z2));
                                cent(I).Bi(:, 1) = squeeze(sum(sum(G, 2) .* repmat(XX, [1, 1, NN]), 1) ./ sum(sum(G, 2), 1));
                                cent(I).Bi(:, 2) = squeeze(sum(sum(G, 1) .* repmat(YY, [1, 1, NN]), 2) ./ sum(sum(G, 2), 1));
                                cent(I).Bi(:, 3) = sum(sum(G, 2), 1);
                                %             cent{I).Ca(:,1) = squeeze(sum(sum(G.*Gc.*Gf,2).*repmat(XX,[1 1 NN]),1)./sum(sum(G.*Gc.*Gf,2),1));
                                %             cent{I).Ca(:,2) = squeeze(sum(sum(G.*Gc.*Gf,1).*repmat(YY,[1 1 NN]),2)./sum(sum(G.*Gc.*Gf,2),1));
                                %             cent{I).Ca(:,3) = squeeze(sum(sum(G.*Gc.*Gf,2),1)./sum(sum(G.*Gf,2),1));
                                %pfpm.increment(I);
                            end
                            MaxFirstRatio = MaxArea ./ FirstArea;
                            %pfpm.delete();
                            AllEvents = AllEvents(:, :, 1:max(Dur(:)) * SamFre);
                            clear A2D E2D E3D
                            t1 = output(sprintf('ALPHA - Final event properties: Calculate duration and maximum projection area done'), whos, toc(tStart), t1);
                            
                            %% Plot MaxProjection vs MaxFirstRatio
                            t1 = output(sprintf('ALPHA - Final event properties: Plot MaxProjection vs MaxFirstRatio start'), whos, toc(tStart), t1);
                            if 0, cf = 'w';
                                cb = 'k'; % ForeGround: 'w', BackGround: 'k'
                            else cf = 'k';
                                cb = 'w'; % ForeGround: 'k', BackGround: 'w'
                            end
                            fig = figure('Position', [100, 100, 600, 400], 'Color', cb, 'Visible', 'on');
                            sub1 = subplot('Position', [.1, .12, .7, .8], 'Color', cb, 'XColor', cf, 'YColor', cf);
                            hold all
                            if numel(unique(MaxArea)) > 2 && numel(unique(MaxFirstRatio)) > 2
                                h2dx = logspace(log10(.9 * double(min(MaxArea(:)))), log10(1.1 * double(max(MaxArea(:)))), 100);
                                h2dy = logspace(log10(.9 * double(1)), log10(1.1 * double(max(MaxFirstRatio(:)))), 50);
                                h2d = hist2w([MaxArea(:), MaxFirstRatio(:)], h2dx, h2dy);
                                h2d(h2d <= 0) = .1;
                                h2d = log10(h2d);
                                contour(sub1, h2dx, h2dy, h2d', 'LevelList', linspace(-1, max(h2d(:)), 32), 'LineStyle', '-', 'LineWidth', .5) %, 'Fill','on', 'LineStyle','none'
                                colormap(color_map(256, 2))
                                set(gca, 'XColor', cf, 'YColor', cf, 'YScale', 'log', 'XScale', 'log', 'XLim', [.9 * h2dx(1), 1.1 * h2dx(end)], 'YLim', [.9 * h2dy(1), 1.1 * h2dy(end)])
                            end
                            xlabel('MaxArea', 'Color', cf);
                            ylabel('MaxArea./FirstArea', 'Color', cf);
                            title('MaxFirstRatio', 'Color', cf);
                            box on
                            box on
                            h = colorbar('Position', [.85, .12, .03, .8]);
                            set(h, 'YTickLabel', num2str(10.^get(h, 'YTick')', '% 10.2f'));
                            set(h, 'XColor', cf, 'YColor', cf, 'XTick', []);
                            set(get(h, 'YLabel'), 'String', 'Frequency', 'Color', cf);
                            drawnow;
                            if par.saveFig
                                chstr = sprintf('results/images/%03d_%02d_MaxProjection_MaxFirstRatio_contour', fn, naps);
                                export_fig(sprintf('%s.png', chstr), '-q100', '-nocrop', fig);
                                close(fig);
                                drawnow;
                            end
                            clear h2d * fig1 sub1
                            t1 = output(sprintf('ALPHA - Final event properties: Histogram Plot MaxProjection vs MaxFirstRatio done'), whos, toc(tStart), t1);
                            
                            %% Save event properties
                            t1 = output(sprintf('ALPHA  - %% Save event properties'), whos, toc(tStart), t1);
                            res(fn).EventInfo = {'Peak3D', 'Peak dF/F'; ...
                                'Mean3D', 'Mean dF/F'; ...
                                'Dur', 'Duration'; ...
                                'MaxArea', 'Maxprojection Area'; ...
                                'Area3D', 'Area x Frame'; ...
                                'FirstArea', '1st projection Area'; ...
                                'Integral', 'Integral'; ...
                                'MaxFirstRatio', 'MaxFirstRatio'; ...
                                'Cen3D', 'Weighted Center 3D'};
                            res(fn).alphaFit(naps).Peak3D = Peak3D; % 'Peak dF/F'
                            res(fn).alphaFit(naps).Mean3D = Mean3D; % 'Mean dF/F'
                            res(fn).alphaFit(naps).Dur = Dur; % 'Duration'
                            res(fn).alphaFit(naps).MaxArea = MaxArea; % 'Maxprojection Area'
                            res(fn).alphaFit(naps).MaxProjArea = MaxProjArea; % 'Maxprojection Area'
                            res(fn).alphaFit(naps).Area3D = Area3D; % 'Area x Frame (time)'
                            res(fn).alphaFit(naps).FirstArea = FirstArea; % '1st projection Area'
                            res(fn).alphaFit(naps).Integral = Integral; % 'Integral'
                            res(fn).alphaFit(naps).MaxFirstRatio = MaxFirstRatio; % 'MaxFirstRatio'
                            res(fn).alphaFit(naps).Cen3D = Cen3D; % 'Cen3D'
                            res(fn).alphaFit(naps).xt = xt; % time
                            res(fn).alphaFit(naps).InitialFrames = InitialFrames;
                            res(fn).alphaFit(naps).MaxFrames = MaxFrames;
                            res(fn).alphaFit(naps).FinalFrames = FinalFrames;
                            res(fn).alphaFit(naps).AllEvents = AllEvents;
                            res(fn).alphaFit(naps).cent = cent;
                            save('results/res_all.mat', 'res')
                            t1 = output(sprintf('ALPHA  - %% event properties saved'), whos, toc(tStart), t1);
                            
                            %% loglog distribution of Time integral
                            t1 = output(sprintf('ALPHA - %% Plot loglog distribution of Time integral start'), whos, toc(tStart), t1);
                            fig = figure('Color', cb, 'Visible', 'on');
                            axes1 = axes('Parent', fig, 'YScale', 'log', 'YMinorTick', 'on', ...
                                'XScale', 'log', 'XMinorTick', 'on');
                            X = Area3D; % 'Area x Frame (time)'
                            if numel(X) > 2
                                %Xstep = linspace(0,max(X),50000);                          %(time * um^2)
                                Xstep = logspace(log(min(X)), log(max(X)), 500);
                                H3D = flipdim(hist(X, Xstep), 2); % linear histogram
                                C3D = flipdim(cumsum(H3D), 2) / sum(H3D) .* max(H3D); % cumulative Histogram
                                %H3Dscaled = H3D / max(H3D);         % normalized linear histogram
                                %C3Dscaled = C3D / max(C3D);         % normalized cumulative histogram
                                hold(axes1, 'all');
                                loglog1 = loglog(Xstep, C3D);
                                loglog2 = loglog(Xstep, flipdim(H3D, 2));
                                set(loglog1(1), 'Marker', 'square')
                                legend('cumulative Area*Time_3_D', 'Area*Time_3_D', 'Location', 'NE')
                            end
                            xlabel('Area3D (Time integral)');
                            ylabel('Frequency');
                            title({'loglog distribution of Time integral'; ...
                                'calc. by Yu-Wei functions'});
                            box on
                            drawnow;
                            if par.saveFig
                                chstr = sprintf('results/images/%03d_%02d_loglog_dist_time_integral', fn, naps);
                                export_fig(sprintf('%s.png', chstr), '-q100', '-nocrop', fig);
                                close(fig);
                                drawnow;
                            end
                            
                            procStr = 'ALPHA - %% loglog distribution of Time integral';
                            clear H3D C3D X Z
                            t1 = output(sprintf('ALPHA - %% Plot loglog distribution of Time integral done'), whos, toc(tStart), t1);
                            
                            %% loglog distribution of Maximum projection area
                            t1 = output(sprintf('ALPHA - %% Plot loglog distribution of Maximum projection area start'), whos, toc(tStart), t1);
                            X = single(MaxArea)';
                            fig = figure('Color', cb, 'Visible', 'on');
                            axes1 = axes('Parent', fig, 'YScale', 'log', 'YMinorTick', 'on', ...
                                'XScale', 'log', 'XMinorTick', 'on');
                            hold(axes1, 'all');
                            if numel(X) > 2
                                %Xstep = linspace(0,max(X),500); %(um^2)
                                Xstep = logspace(log(min(X)), log(max(X)), 500);
                                H3D = flipdim(hist(X, Xstep), 2); % linear histogram
                                C3D = flipdim(cumsum(H3D), 2) / sum(H3D) .* max(H3D); % cumulative Histogram
                                %H3Dscaled = H3D / max(H3D);         % normalized linear histogram
                                %C3Dscaled = C3D / max(C3D);         % normalized cumulative histogram
                                hold(axes1, 'all');
                                loglog1 = loglog(Xstep, C3D);
                                loglog2 = loglog(Xstep, flipdim(H3D, 2));
                                set(loglog1(1), 'Marker', 'square')
                                legend('MaxProjection', 'Location', 'NE')
                            end
                            xlabel('MaxArea');
                            ylabel('Frequency');
                            title({'loglog distribution of Maximum projection area'; 'calc. by Yu-Wei functions'});
                            box on
                            drawnow;
                            if par.saveFig
                                chstr = sprintf('results/images/%03d_%02d_loglog_dist_max_proj_area', fn, naps);
                                export_fig(sprintf('%s.png', chstr), '-q100', '-nocrop', fig);
                                close(fig);
                                drawnow;
                            end
                            clear H3D C3D X Z
                            t1 = output(sprintf('ALPHA - %% Plot loglog distribution of Maximum projection area done'), whos, toc(tStart), t1);
                            %          %% loglog distribution of Duration
                            t1 = output(sprintf('ALPHA - %% Plot loglog distribution of Duration start'), whos, toc(tStart), t1);
                            fig = figure('Color', cb, 'Visible', 'on');
                            axes1 = axes('Parent', fig, 'YScale', 'log', 'YMinorTick', 'on', ...
                                'XScale', 'log', 'XMinorTick', 'on');
                            hold(axes1, 'all');
                            X = single(Dur);
                            if numel(X) > 2
                                %Xstep = linspace(0,max(X),500);
                                Xstep = logspace(log(min(X)), log(max(X)), 500);
                                H3D = flipdim(hist(X, Xstep), 2); % linear histogram
                                C3D = flipdim(cumsum(H3D), 2) / sum(H3D) .* max(H3D); % cumulative Histogram
                                %H3Dscaled = H3D / max(H3D);         % normalized linear histogram
                                %C3Dscaled = C3D / max(C3D);         % normalized cumulative histogram
                                loglog1 = loglog(Xstep, C3D);
                                loglog2 = loglog(Xstep, flipdim(H3D, 2));
                                set(loglog1(1), 'Marker', 'square')
                                legend('D', 'Location', 'NE')
                            end
                            xlabel('Duration / s');
                            ylabel('Frequency');
                            title({'loglog distribution of Duration'; 'calc. by Yu-Wei functions'});
                            box on
                            hold off
                            clear H3D C3D X Z
                            drawnow;
                            if par.saveFig
                                chstr = sprintf('results/images/%03d_%02d_loglog_dist_duration', fn, naps);
                                export_fig(sprintf('%s.png', chstr), '-q100', '-nocrop', fig);
                                close(fig);
                                drawnow;
                            end
                            t1 = output(sprintf('ALPHA - %% Plot loglog distribution of Duration done'), whos, toc(tStart), t1);
                            
                            %% Fit alpha value (functions by Aron Clauset)
                            t1 = output(sprintf('ALPHA - Fit alpha value (functions by Aron Clauset)'), whos, toc(tStart), t1);
                            if numel(unique(Area3D)) > 2
                                [alpha.Area3D, xmin.Area3D, L.Area3D] = plfit(double(Area3D)); %,'limit',5000
                                t1 = output(sprintf('ALPHA - plfit(double(Area3D) calculated'), whos, toc(tStart), t1);
                            else
                                alpha.Area3D = 1;
                                xmin.Area3D = 1;
                                L.Area3D = 1;
                                t1 = output(sprintf('ALPHA - too few recognized events NO Area3D values calculated'), whos, toc(tStart), t1);
                            end
                            if numel(unique(MaxArea)) > 2
                                [alpha.MaxArea, xmin.MaxArea, L.MaxArea] = plfit(double(MaxArea)); %,'limit',100
                                t1 = output(sprintf('ALPHA - plfit(double(MaxArea)) calculated'), whos, toc(tStart), t1);
                            else
                                alpha.MaxArea = 1;
                                xmin.MaxArea = 1;
                                L.MaxArea = 1;
                                t1 = output(sprintf('ALPHA - too few recognized events NO MaxArea values calculated'), whos, toc(tStart), t1);
                            end
                            if numel(unique(Dur)) > 2
                                [alpha.Dur, xmin.Dur, L.Dur] = plfit(double(Dur));
                                t1 = output(sprintf('ALPHA - plfit(double(Dur)) calculated'), whos, toc(tStart), t1);
                            else
                                alpha.Dur = 1;
                                xmin.Dur = 1;
                                L.Dur = 1;
                                t1 = output(sprintf('ALPHA - too few recognized events NO Dur values calculated'), whos, toc(tStart), t1);
                            end
                            
                            res(fn).alphaFit(naps).alpha = alpha;
                            res(fn).alphaFit(naps).xmin = xmin;
                            res(fn).alphaFit(naps).L = L;
                            save('results/res_all.mat', 'res')
                            t1 = output(sprintf('ALPHA  - %% FIT properties saved'), whos, toc(tStart), t1);
                            
                            %% Area3D
                            t1 = output(sprintf('ALPHA  - %% prepare Area3D Histogram plot (functions by Aron Clauset)'), whos, toc(tStart), t1);
                            if numel(unique(Area3D)) > 2
                                h = plplot(double(Area3D), xmin.Area3D, alpha.Area3D);
                                fig = gcf;
                            else
                                fig = figure;
                            end
                            set(fig, 'Color', cb, 'Visible', 'on');
                            xlabel('Area3D');
                            title({'loglog distribution of Time integral'; ...
                                '{\fontsize{12}calc. by ''plfit.m'' & ''plplot.m'''; ...
                                'Aaron Clauset (http://www.santafe.edu/~aaronc/powerlaws/)}'});
                            hold on;
                            plot(xmin.Area3D * [1, 1], [1, 1e-5], ':r')
                            text(1.5 * xmin.Area3D, 5e-3, ...
                                {sprintf('x_{min} = %d', xmin.Area3D); ...
                                sprintf('N_{tot.} = %d', numel(Area3D)); ...
                                sprintf('N_{xmin} = %d', sum(Area3D >= xmin.Area3D)); ...
                                sprintf('L = %d', L.Area3D)}, 'Color', 'r', 'VerticalAlignment', 'Bottom')
                            text(5 * xmin.Area3D, 5e-1, sprintf('Alpha = %4.2f', alpha.Area3D), 'Color', 'k')
                            drawnow;
                            if par.saveFig
                                chstr = sprintf('results/images/%03d_%02d_loglog_dist_time_integral_AC', fn, naps);
                                export_fig(sprintf('%s.png', chstr), '-q100', '-nocrop', fig);
                                close(fig);
                                drawnow;
                            end
                            t1 = output(sprintf('ALPHA  - %% Area3D Histogram plot saved(functions by Aron Clauset)'), whos, toc(tStart), t1);
                            
                            %% MaxArea
                            t1 = output(sprintf('ALPHA  - %% prepare MaxArea Histogram plot (functions by Aron Clauset)'), whos, toc(tStart), t1);
                            if numel(unique(MaxArea)) > 2
                                h = plplot(double(MaxArea), xmin.MaxArea, alpha.MaxArea);
                                fig = gcf;
                            else
                                fig = figure;
                            end
                            set(fig, 'Color', cb, 'Visible', 'on');
                            xlabel('MaxArea');
                            title({'loglog distribution of Maximum projection area'; ...
                                '{\fontsize{12}calc. by ''plfit.m'' & ''plplot.m'''; ...
                                'Aaron Clauset (http://www.santafe.edu/~aaronc/powerlaws/)}'});
                            hold on;
                            plot(xmin.MaxArea * [1, 1], [1, 1e-5], ':r')
                            text(1.5 * xmin.MaxArea, 5e-3, ...
                                {sprintf('x_{min} = %d', xmin.MaxArea); ...
                                sprintf('N_{tot.} = %d', numel(MaxArea)); ...
                                sprintf('N_{xmin} = %d', sum(MaxArea >= xmin.MaxArea)); ...
                                sprintf('L = %d', L.MaxArea)}, 'Color', 'r', 'VerticalAlignment', 'Bottom')
                            text(5 * xmin.MaxArea, 5e-1, sprintf('Alpha = %4.2f', alpha.MaxArea), 'Color', 'k')
                            drawnow;
                            if par.saveFig
                                chstr = sprintf('results/images/%03d_%02d_loglog_dist_max_proj_area_AC', fn, naps);
                                export_fig(sprintf('%s.png', chstr), '-q100', '-nocrop', fig);
                                close(fig);
                                drawnow;
                            end
                            t1 = output(sprintf('ALPHA  - %% MaxArea Histogram plot saved(functions by Aron Clauset)'), whos, toc(tStart), t1);
                            
                            %% Duration
                            t1 = output(sprintf('ALPHA  - %% prepare Duration Histogram plot (functions by Aron Clauset)'), whos, toc(tStart), t1);
                            if numel(unique(Dur)) > 2
                                h = plplot(double(Dur), xmin.Dur, alpha.Dur);
                                fig = gcf;
                            else
                                fig = figure;
                            end
                            set(fig, 'Color', cb, 'Visible', 'on');
                            xlabel('Duration / s');
                            title({'loglog distribution of Duration'; ...
                                '{\fontsize{12}calc. by ''plfit.m'' & ''plplot.m'''; ...
                                'Aaron Clauset (http://www.santafe.edu/~aaronc/powerlaws/)}'});
                            hold on;
                            plot(xmin.Dur * [1, 1], [1, 1e-5], ':r')
                            text(1.5 * xmin.Dur, 5e-3, ...
                                {sprintf('x_{min} = %4.3f', xmin.Dur); ...
                                sprintf('N_{tot.} = %d', numel(Dur)); ...
                                sprintf('N_{xmin} = %d', sum(Dur >= xmin.Dur)); ...
                                sprintf('L = %d', L.Dur)}, 'Color', 'r', 'VerticalAlignment', 'Bottom')
                            text(5 * xmin.Dur, 5e-1, sprintf('Alpha = %4.2f', alpha.Dur), 'Color', 'k')
                            drawnow;
                            if par.saveFig
                                chstr = sprintf('results/images/%03d_%02d_loglog_dist_duration_AC', fn, naps);
                                export_fig(sprintf('%s.png', chstr), '-q100', '-nocrop', fig);
                                close(fig);
                                drawnow;
                            end
                            t1 = output(sprintf('ALPHA  - %% Duration Histogram plot saved(functions by Aron Clauset)'), whos, toc(tStart), t1);
                            
                            %% clear memory
                            clear Ca * F * A3D MM Cen3D * Area3D Integral Max * Mean3D Peak3D InstFre Dur cent G * AllEvents
                        end
                        
                    end
                    
                    %% Ca2+ imaging display (requires 3d over time)
                    % if you run 'Alpha Value Analysis' before you have only 2d over time!!!
                    if par.Ca2.Ca2_movie_generation
                        sz = size(dbg);
                        lsz = length(sz);
                        
                        %% create application image
                        if par.application
                            t1 = output('create application figure', whos, toc(tStart), t1);
                            fig = figure('Color', cb, 'Visible', 'off');
                            nap_times = size(res(fn).ap_times, 1);
                            ha1 = axes('Visible', 'on', 'Parent', fig, 'Units', 'normalized', 'Position', [0.1, .85, .85, .05], ...
                                'Color', 'none', 'XColor', cb, 'YColor', cb);
                            hold(ha1, 'all')
                            %fk ={'b','g','r','m'};
                            for n = 1:nap_times
                                rectangle('Parent', ha1, 'Position', [res(fn).ap_times(n, 1), 0.05, res(fn).ap_times(n, 2) - res(fn).ap_times(n, 1), .9], 'Curvature', [0, 0], 'FaceColor', res(fn).ap_tcol(n, :))
                                text('Parent', ha1, 'Position', [res(fn).ap_times(n) + 1, .5], 'String', res(fn).ap_tits(n), ...
                                    'Color', cf, 'Clipping', 'on', 'FontWeight', 'bold')
                            end
                            xlim([0, xt(end)])
                            ylim([0, 1])
                            title(fileList(fn).name, 'Interpreter', 'none', 'Color', cf)
                            
                            ha2 = axes('Visible', 'on', 'Parent', fig, 'Units', 'normalized', 'Position', [.1, .09, .85, .7], ...
                                'Color', 'none', 'XColor', cf, 'YColor', cf);
                            t1 = output('Calculate figure traces', whos, toc(tStart), t1);
                            dbg = reshape(dbg, [prod(sz(1:end - 1)), sz(end)]);
                            dp = zeros(sz(end), 1, 'single');
                            dm = zeros(sz(end), 1, 'single');
                            ds = zeros(sz(end), 1, 'single');
                            for n = 1:sz(end);
                                dp(n) = single(dip_percentile(dbg(:, n), [], 90, []));
                                dm(n) = mean(dbg(dbg(:, n) > dp(n), n));
                                ds(n) = std(dbg(dbg(:, n) > dp(n), n));
                            end
                            dbg = reshape(dbg, sz);
                            t1 = output('figure traces calculated', whos, toc(tStart), t1);
                            hold(ha2, 'all');
                            plot(xt, dp); %/mean(dp(1:10))
                            plot(xt, dm); %/mean(dm(1:10))
                            plot(xt, ds / mean(ds(1:10)) * mean(dm(1:10))); %
                            %plot(xt,ds/mean(ds(1:10))./dm*mean(dm(1:10)));
                            legend({'90% percentile', 'mean of high values', 'std of high values'}, 'Location', 'best', 'TextColor', cf)
                            hold(ha2, 'off');
                            xlim([0, xt(end)])
                            xlabel('time / min');
                            ylabel('Dntensity in DL (std scaled to mean int.)');
                            box on
                            if par.saveFig
                                export_fig(sprintf('results/images/%03d_application_profile.png', fn), '-q100', '-nocrop', fig); % '-transparent', One might choose a renderer, default figure handle is gcf.
                                close(fig);
                                drawnow;
                            end
                            clear fig ha * nap_times dp dm ds
                            t1 = output('application figure created', whos, toc(tStart), t1);
                        end
                        
                        %% compress files for visualization
                        nd = floor(20 * sz(end) / (60 * xt(end)) / 15);
                        if nd > 1
                            t1 = output(sprintf('start data binning for optimal video settings with %dx binning in time', nd), whos, toc(tStart), t1);
                            % REQUIRE MANUAL BINNING SINCE FUNCTION IS NASTY
                            %dbg = binning(dbg,[1 1 1 nd],'mean');%dbg(:,:,:,1:nd:end);
                            dbg = reshape(dbg, [prod(sz(1:end - 1)), sz(end)]);
                            sze = (nd * floor(sz(end) / nd));
                            if sze < sz(end), dbg = dbg(:, 1:sze);
                            end
                            dbg = reshape(dbg, [prod(sz(1:end - 1)), nd, sze / nd]);
                            dbg = mean(dbg, 2);
                            dbg = reshape(dbg, [sz(1:end - 1), sze / nd]);
                            % REQUIRE MANUAL BINNING SINCE FUNCTION IS NASTY
                            xt = xt(1:nd:end);
                            sz = size(dbg);
                            lsz = length(sz);
                            t1 = output(sprintf('data binning complete'), whos, toc(tStart), t1);
                        end
                        if par.application;
                            ap_times_frame = round(res(fn).ap_times_frame / nd);
                        end
                        
                        %% Ca2+ imaging 2d
                        %ca:  1 Ca2+ imaging cardiac tissue
                        %     2 Ca2+ astrocyte
                        ca = 1;
                        % z-maximum projection
                        d = squeeze(max(dbg, [], 3));
                        t1 = output('max projection', whos, toc(tStart), t1);
                        d = scaleMinMax(single(d)); %d = single(stretch(d,0,99.99,0,1)); %2*ch1/max(ch1(:));
                        t1 = output('stretch mode calculated', whos, toc(tStart), t1);
                        d(d > 1) = 1;
                        t1 = output('start low Ca2+ signal calculation (F_0)', whos, toc(tStart), t1);
                        sz1 = size(d);
                        lsz = length(sz1);
                        switch ca
                            case 1 % Ca2+ imaging including bleaching and cell movement (time dependend F_0)
                                if numel(d) > 5e6
                                    t1 = output('start parallel computing for sliding F_0 calculation', whos, toc(tStart), t1);
                                    %d    = reshape(d,[prod(sz1(1:2)) sz1(3)]);
                                    d_pf = zeros(sz1, 'single'); %zeros([prod(sz1(1:2)), sz1(3)],'single');
                                    N = sz(1); %prod(sz1(1:2));
                                    %if par.ParforProgress2; %pfpm = ParforProgress2('z-max proj.:  calc F_0 percf', N, 1, 0, 1); end
                                    parfor n = 1:N
                                        d_pf(n, :, :) = single(percf(d(n, :, :), 10, [0, 0, 100], 'elliptic'));
                                        %if par.ParforProgress2; %pfpm.increment();end
                                    end
                                    %if par.ParforProgress2; pfpm.delete(); end
                                    d = reshape(d, sz1);
                                    d_pf = reshape(d_pf, sz1);
                                    t1 = output('parallel computing for sliding F_0 calculation done', whos, toc(tStart), t1);
                                else
                                    t1 = output('start F_0 calculation', whos, toc(tStart), t1);
                                    d_pf = single(percf(d, 10, [0, 0, 100], 'elliptic'));
                                end
                                Ar = d ./ d_pf;
                                t1 = output('F/F0 calculated', whos, toc(tStart), t1);
                                d_pf = single(scaleMinMax(d_pf));
                                t1 = output('low Ca2+ signal (F_0) calculated', whos, toc(tStart), t1);
                            case 2 % Ca2+ astrocyte (global F_0)
                                % manually calculate 10% percentile of each pixel trace
                                d = reshape(d, [prod(sz1(1:end - 1)), sz1(end)]);
                                d_pf = sort(permute(single(d), [2, 1]), 1);
                                d_pf = single(d_pf(.1 * sz1(end), :));
                                d_pf = reshape(d_pf, sz1(1:2));
                                %d_pf = repmat(d_pf,[1 1 sz1(3)]);
                                d = reshape(d, sz1);
                                Ar = d ./ repmat(d_pf, [1, 1, sz1(3)]);
                                t1 = output('F/F0 calculated', whos, toc(tStart), t1);
                                d_pf = d_pf / max(d_pf(:));
                                t1 = output('low Ca2+ signal (F_0) calculated', whos, toc(tStart), t1);
                        end
                        %ratio_image_adjust(truncate(Ar,0,10,1),repmat(d_pf.^.5,[1 1 sz1(3)]), 'rLim', [.5 2.4], 'iLim', [.02 .8])
                        t1 = output('create ratioimage 2d', whos, toc(tStart), t1);
                        
                        %% Ca2+ animated gif including adjustment
                        %{
              aR = min(sz(2)/sz(1)*.5+.1,.6);
              ratio_image_adjust(truncate(Ar,0,10,1),d_pf.^.75, 'rLim', [1 10], 'iLim', [0 .8],...
                'colorBar','F / F_0', 'timeVector', xt,...
                'aspectRatio',aR,...
                'movieMethod',3,'position',[10 200 300 400],'movieName',['results/images/' num2str(fn,'%03.0f') '_ca2+_ani.gif']...,'legend',leg
                );
              disp('save trace movie - Pause')
              %pause % search for Xiaofang
                        %}
                        
                        %% Ca2+ 2d avi movie
                        t1 = output('start 2d Ca2+ movie creation', whos, toc(tStart), t1);
                        sz1 = size(Ar);
                        fig = figure('Color', cb, 'Position', [100, 100, sz(2) + 100, sz(1)], 'Visible', 'off');
                        limR = [1, 5];
                        limI = [0.05, 0.5];
                        switch ca
                            case 1 % Ca2+ imaging including bleaching and cell movement (time dependend F_0)
                                [rgb_ratio, ibar.r_space, ibar.i_space, ibar.rgb_space] = ratio_image(truncate(max(Ar, [], 3), 0, 20, 1), max(d_pf, [], 3), limR(1), limR(2), limI(1), limI(2), 1); %.75
                            case 2 % Ca2+ of stabile astrocyte (global F_0)
                                [rgb_ratio, ibar.r_space, ibar.i_space, ibar.rgb_space] = ratio_image(truncate(max(Ar, [], 3), 0, 20, 1), d_pf, limR(1), limR(2), limI(1), limI(2), 1); %.75
                        end
                        ibar.label = 'F/F_0';
                        ha1 = subplot('Position', [0, 0, sz(2) / (sz(2) + 100), 1]);
                        h = image(squeeze(rgb_ratio));
                        set(ha1, 'XTick', [], 'YTick', [])
                        if par.application
                            apn = 1;
                            ht = text('String', {sprintf('{\\color{yellow}%02d:%05.2f min}', 0, 0); ...
                                sprintf('{\\color{yellow}x %d}', videoPlaySpeed); ...
                                sprintf('{\\color[rgb]{%f %f %f}%s}', res(fn).ap_tcol(apn, :), res(fn).ap_tits{apn})}, ...
                                'Units', 'normalized', 'Position', [.02, .98], 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
                            %text(.1,.5,['\fontsize{16}black {\color{magenta}magenta \color[rgb]{0 .5 .5}teal \color{red}red} black again'])
                        else
                            ht = text('String', {sprintf('%02d:%05.2f min', 0, 0); sprintf('x %d', videoPlaySpeed);}, 'Units', 'normalized', ...
                                'Position', [.02, .98], 'Color', 'y', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
                        end
                        %ht=text('String',{sprintf('% 4.2f s',60*xt(1));'x10'},'Units','normalized','Position',[.15 .95],'Color','y','HorizontalAlignment','center');
                        ha2 = axes('OuterPosition', [sz(2) / (sz(2) + 100), 0, 100 / (sz(2) + 100), 1]);
                        image(ibar.i_space, ibar.r_space, ibar.rgb_space);
                        axis tight;
                        set(ha2, 'YAxisLocation', 'right', 'YDir', 'normal', 'Color', cb, 'XColor', cf, 'YColor', cf, 'XTick', []);
                        ylabel(ibar.label, 'Color', cf)
                        chstr = sprintf('results/images/%03d_overview', fn);
                        export_fig(sprintf('%s.png', chstr), '-q100', '-nocrop', fig);
                        rgb_ratio = ratio_image(truncate(Ar(:, :, 1), 0, 20, 1), d_pf(:, :, 1), limR(1), limR(2), limI(1), limI(2), 1); %.75
                        set(h, 'CData', squeeze(rgb_ratio))
                        chstr = sprintf('results/images/%03d_time_F_F0_maxProj', fn);
                        export_fig(sprintf('%s.png', chstr), '-q100', '-nocrop', fig);
                        t1 = output('preview image saved', whos, toc(tStart), t1);
                        N = sz1(3);
                        rgb_ratio = zeros([sz1(1:2), 3, sz1(3)], 'single');
                        %if par.ParforProgress2;  %pfpm = ParforProgress2('calculating Ca2+ 2d avi movie (parallel mode)', N, 1, 0,1);end
                        switch ca
                            case 1 % Ca2+ imaging including bleaching and cell movement (time dependend F_0)
                                parfor n = 1:N
                                    rgb_ratio(:, :, :, n) = ratio_image(truncate(Ar(:, :, n), 0, 20, 1), d_pf(:, :, n), limR(1), limR(2), limI(1), limI(2), 1); %.75
                                    %if par.ParforProgress2; %pfpm.increment();end
                                end
                            case 2 % Ca2+ of stabile astrocyte (global F_0)
                                parfor n = 1:N
                                    rgb_ratio(:, :, :, n) = ratio_image(truncate(Ar(:, :, n), 0, 20, 1), d_pf, limR(1), limR(2), limI(1), limI(2), 1); %.75
                                    %if par.ParforProgress2; %pfpm.increment();end
                                end
                        end
                        %if par.ParforProgress2; %pfpm.delete();end
                        t1 = output('RGB matrix calculated', whos, toc(tStart), t1);
                        %writer object
                        writerobj = VideoWriter(sprintf('%s.mp4', chstr), 'MPEG-4');
                        writerobj.FrameRate = videoPlaySpeed * sz(end) / (60 * xt(end));
                        open(writerobj);
                        % set figure properties
                        hh = myHardcopyFigureSet(fig, 3);
                        %if par.ParforProgress2;  %pfpm = ParforProgress2('writing Ca2+ 2d avi movie (stripe mode)', N, 1, 0,1);end
                        for n = 1:N
                            set(h, 'CData', squeeze(rgb_ratio(:, :, :, n)))
                            if par.application
                                apn = sum(n >= ap_times_frame(:, 1));
                                set(ht, 'String', {sprintf('{\\color{yellow}%02d:%05.2f min}', floor(xt(n)), 60 * xt(n) - 60 * floor(xt(n))); ...
                                    sprintf('{\\color{yellow}x %d}', videoPlaySpeed); ...
                                    sprintf('{\\color[rgb]{%f %f %f}%s}', res(fn).ap_tcol(apn, :), res(fn).ap_tits{apn})});
                            else
                                set(ht, 'String', {sprintf('%02d:%05.2f min', floor(xt(n)), 60 * xt(n) - 60 * floor(xt(n))); sprintf('x %d', videoPlaySpeed)})
                            end
                            %set(ht,'String',{sprintf('% 4.2f s',60*xt(n));'x10'})
                            drawnow;
                            A = myHardcopy(fig, hh, 3);
                            %A=export_fig(fig,'-q100','-nocrop');
                            writeVideo(writerobj, A);
                            %if par.ParforProgress2; %pfpm.increment();end
                        end
                        %if par.ParforProgress2; %pfpm.delete();end
                        close(writerobj);
                        t1 = output('2d Ca2+ movie saved as mp4', whos, toc(tStart), t1);
                        %myHardcopyFigureReset(fig, hh);
                        system(sprintf('ffmpeg.exe -i %s.mp4 -vcodec libtheora -y %s.ogg -nostats -loglevel panic', chstr, chstr));
                        t1 = output('2d Ca2+ movie saved as ogg', whos, toc(tStart), t1);
                        close(fig);
                        drawnow;
                        clear chstr fig h ht ha * A * writerobj rgb_ratio ibar lim *
                        t1 = output('2d Ca2+ movie saving finished', whos, toc(tStart), t1);
                        
                        %% raw data max projection (using single precision)
                        %       t1 = output('Start Image generation section', whos, toc(tStart), t1);
                        %       d = squeeze(max(dbg,[],3));
                        %       t1 = output('max projection', whos, toc(tStart), t1);
                        %       d = single(stretch(d,0,99.99,0,1)); %2*ch1/max(ch1(:));
                        %       t1 = output('stretch mode calculated', whos, toc(tStart), t1);
                        %       d(d>1) = 1;
                        limI(1) = single(dip_percentile(d(:), [], .1, []));
                        limI(2) = single(dip_percentile(d(:), [], 99.9999, []));
                        d = uint8(255 * (scaleMinMax(d, limI(1), limI(2)).^.75));
                        sz1 = size(d);
                        cmap = single(color_map(256, 9)); %Black - Green - White
                        d = cmap(d(:) + 1, :);
                        d = reshape(d, [sz1, 3]);
                        t1 = output('max Projection Channel 1 movie (4D) created', whos, toc(tStart), t1);
                        sz1 = size(d);
                        chstr = sprintf('results/images/%03d_time_raw_maxProj', fn);
                        fig = figure('Position', [100, 100, sz(2), sz(1)], 'Visible', 'off');
                        h = image(squeeze(max(d, [], 3)));
                        set(gca, 'XTick', [], 'YTick', [], 'Units', 'normalized', 'Position', [0, 0, 1, 1])
                        if par.application
                            apn = 1;
                            ht = text('String', {sprintf('{\\color{yellow}%02d:%05.2f min}', 0, 0); ...
                                sprintf('{\\color{yellow}x %d}', videoPlaySpeed); ...
                                sprintf('{\\color[rgb]{%f %f %f}%s}', res(fn).ap_tcol(apn, :), res(fn).ap_tits{apn})}, ...
                                'Units', 'normalized', 'Position', [.02, .98], 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
                        else
                            ht = text('String', {sprintf('%02d:%05.2f min', 0, 0); sprintf('x %d', videoPlaySpeed)}, 'Units', 'normalized', ...
                                'Position', [.02, .98], 'Color', 'y', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
                        end
                        % preview image
                        export_fig(sprintf('%s.png', chstr), '-q100', '-nocrop', fig);
                        t1 = output('preview image saved', whos, toc(tStart), t1);
                        %if par.ParforProgress2;  %pfpm = ParforProgress2('writing raw data max projection movie (stripe mode)', N, 1, 0,1);end
                        %writer object
                        writerobj = VideoWriter(sprintf('%s.mp4', chstr), 'MPEG-4');
                        writerobj.FrameRate = videoPlaySpeed * sz(end) / (60 * xt(end));
                        open(writerobj);
                        % set figure properties
                        hh = myHardcopyFigureSet(fig, 3);
                        for n = 1:sz1(3)
                            set(h, 'CData', squeeze(d(:, :, n, :)))
                            if par.application
                                apn = sum(n >= ap_times_frame(:, 1));
                                set(ht, 'String', {sprintf('{\\color{yellow}%02d:%05.2f min}', floor(xt(n)), 60 * xt(n) - 60 * floor(xt(n))); ...
                                    sprintf('{\\color{yellow}x %d}', videoPlaySpeed); ...
                                    sprintf('{\\color[rgb]{%f %f %f}%s}', res(fn).ap_tcol(apn, :), res(fn).ap_tits{apn})});
                            else
                                set(ht, 'String', {sprintf('%02d:%05.2f min', floor(xt(n)), 60 * xt(n) - 60 * floor(xt(n))); ...
                                    sprintf('x %d', videoPlaySpeed)})
                            end
                            drawnow;
                            A = myHardcopy(fig, hh, 3);
                            writeVideo(writerobj, A);
                            %if par.ParforProgress2; %pfpm.increment();end
                        end
                        %if par.ParforProgress2; %pfpm.delete();end
                        close(writerobj);
                        t1 = output('max Projection movie (4D): mp4 saved', whos, toc(tStart), t1);
                        %myHardcopyFigureReset(fig, hh);
                        system(sprintf('ffmpeg.exe -i %s.mp4 -vcodec libtheora -y %s.ogg -nostats -loglevel panic', chstr, chstr));
                        t1 = output('max Projection movie (4D): ogg saved', whos, toc(tStart), t1);
                        close(fig);
                        drawnow;
                        clear d chstr fig h ht A writerobj
                        t1 = output('max Projection movie (4D): finished', whos, toc(tStart), t1);
                        
                        %% Volumen Display: 3d rendering (using single precision)
                        if par.saveRenderingVideo
                            t1 = output('start 3d data rendering', whos, toc(tStart), t1);
                            switch par.type
                                case 1
                                    dxz = acq.lsm_info.VoxelSizeX / acq.lsm_info.VoxelSizeZ;
                                case 2
                                    dxz = acq.x / acq.seq.Z_Step;
                            end
                            %d = scaleMinMax(dbg);% single(stretch(dbg,0,99.99,0,1)); %2*ch1/max(ch1(:));
                            %t1 = output('data Scaled to 1', whos, toc(tStart), t1);
                            %d(d>1) = 1;
                            %d = uint8(255*(d.^.75));
                            %d = flipdim(flipdim(d,3),4);
                            %sz1 = size(d);
                            %t1 = output('data set gamma corrected', whos, toc(tStart), t1);
                            cmap = single(color_map(256, 9)); % Black - Green - White
                            %d = cmap(d(:)+1,:);
                            %d = reshape(d,[sz1 3]);
                            %t1 = output('data prepared', whos, toc(tStart), t1);
                            chstr = sprintf('results/images/%03d_time_raw_render3d', fn);
                            create3dRenderTimeMovie(dbg, [1, 1, dxz], chstr, cmap, 60 * xt)
                            clear cmap chstr
                        end
                        
                        %% 3d Ca2+ rendering for astrocyte
                        if par.saveRenderingVideo
                            
                            %% calc baseline level
                            t1 = output('3d Ca2+ rendering: Start rendering for astrocytes', whos, toc(tStart), t1);
                            sz = size(dbg);
                            lsz = length(sz);
                            switch ca
                                case 1 % Ca2+ imaging cardiac tissue (time dependend F_0)
                                    if numel(dbg) > 1e6
                                        t1 = output('3d Ca2+ rendering: start parallel computing for sliding F_0 calculation', whos, toc(tStart), t1);
                                        dbg = reshape(dbg, [sz(1), prod(sz(2:3)), sz(4)]);
                                        d_pf = zeros([sz(1), prod(sz(2:3)), sz(4)], 'single');
                                        N = sz(1); %prod(sz(1:3));
                                        %if par.ParforProgress2; %pfpm = ParforProgress2('3d data:  calc F_0 percf', N, 1, 0, 1); end
                                        parfor n = 1:N
                                            d_pf(n, :, :) = single(percf(dbg(n, :, :), 10, [0, 0, 100], 'elliptic'));
                                            %if par.ParforProgress2; %pfpm.increment();end
                                        end
                                        %if par.ParforProgress2; %pfpm.delete(); end
                                        dbg = reshape(dbg, sz);
                                        d_pf = reshape(d_pf, sz);
                                        t1 = output('3d Ca2+ rendering: parallel computing for sliding F_0 calculation done', whos, toc(tStart), t1);
                                    else
                                        t1 = output('3d Ca2+ rendering: start F_0 calculation', whos, toc(tStart), t1);
                                        d_pf = single(percf(dbg, 10, [0, 0, 0, 100], 'elliptic'));
                                        t1 = output('3d Ca2+ rendering: F_0 calculation done', whos, toc(tStart), t1);
                                    end
                                    %Ai = single(scaleMinMax(d_pf));
                                case 2 % Ca2+ astrocyte (global F_0)
                                    % manually calculate 10% percentile of each pixel trace
                                    dbg = reshape(dbg, [prod(sz(1:end - 1)), sz(end)]);
                                    sz1 = size(dbg);
                                    d_pf = sort(permute(single(dbg), [2, 1]), 1);
                                    d_pf = single(d_pf(.1 * sz1(2), :));
                                    t1 = output('3d Ca2+ rendering: F_0 calculated', whos, toc(tStart), t1);
                                    % Rdbg = Rdbg./repmat(trp(:),[1 sz(4)]);
                                    d_pf = reshape(d_pf, sz(1:3));
                                    dbg = reshape(dbg, sz(1:4));
                            end
                            
                            %% rendering function
                            functionname = 'render.m';
                            functiondir = which(functionname);
                            functiondir = functiondir(1:end - length(functionname));
                            if isempty(regexpi(path, functiondir))
                                addpath(functiondir);
                                addpath([functiondir, '/SubFunctions']);
                            end
                            
                            %% rendering vector
                            vec = [0, 60, 20];
                            options = [];
                            options.RenderType = 'mip';
                            options.ColorTable = [1, 0, 0; 1, 0, 0; 1, 0, 0; 1, 0, 0; 1, 0, 0; 1, 0, 0; 1, 0, 0];
                            options.ImageSize = [300, 600];
                            options.Mview = makeViewMatrix(vec, .95 * [1, 1, dxz], [0, 0, 0]);
                            t1 = output('3d Ca2+ rendering: render vector created', whos, toc(tStart), t1);
                            %stopHere
                            
                            %% rendering with parallel computing
                            t1 = output('3d Ca2+ rendering: start rendering with parallel computing!', whos, toc(tStart), t1);
                            sz1 = [sz(1:3), 3];
                            N = sz(end);
                            I1 = zeros([options.ImageSize, 3, N], 'uint8');
                            %if par.ParforProgress2; %pfpm = ParforProgress2('3d data:  rendering with parallel computing', N, 1, 0, 1);end
                            limR = [1, 10];
                            limI = [0.05, 0.5 * max(d_pf(:))];
                            [rgb_ratio, ibar.r_space, ibar.i_space, ibar.rgb_space] = ratio_image(truncate(dbg(:, :, :, 1) ./ d_pf(:, :, :, 1), 0, 20, 1), d_pf(:, :, :, 1), limR(1), limR(2), limI(1), limI(2), 1);
                            ibar.label = 'F/F_0';
                            switch ca
                                case 1 % Ca2+ imaging cardiac tissue (time dependend F_0)
                                    parfor n = 1:N %
                                        Rdbg = dbg(:, :, :, n) ./ d_pf(:, :, :, n);
                                        RGBStack = ratio_image(truncate(Rdbg, 0, 20, 1), d_pf(:, :, :, n), limR(1), limR(2), limI(1), limI(2), 1);
                                        ii = uint8(255 * render(RGBStack(:, :, :, 1), options)); %.^.75;
                                        ii(:, :, 2) = uint8(255 * render(RGBStack(:, :, :, 2), options));
                                        ii(:, :, 3) = uint8(255 * render(RGBStack(:, :, :, 3), options));
                                        I1(:, :, :, n) = ii;
                                        %if par.ParforProgress2; %pfpm.increment();end;
                                    end
                                case 2 % Ca2+ astrocyte (global F_0)
                                    parfor n = 1:N %
                                        Rdbg = dbg(:, :, :, n) ./ d_pf;
                                        RGBStack = ratio_image(truncate(Rdbg, 0, 20, 1), d_pf, limR(1), limR(2), limI(1), limI(2), 1);
                                        ii = uint8(255 * render(RGBStack(:, :, :, 1), options)); %.^.75;
                                        ii(:, :, 2) = uint8(255 * render(RGBStack(:, :, :, 2), options));
                                        ii(:, :, 3) = uint8(255 * render(RGBStack(:, :, :, 3), options));
                                        I1(:, :, :, n) = ii;
                                        %if par.ParforProgress2; %pfpm.increment();end;
                                    end
                            end
                            %if par.ParforProgress2; %pfpm.delete();end;
                            t1 = output('3d Ca2+ rendering: rendering complete, start video capturing', whos, toc(tStart), t1);
                            
                            %% create movie
                            chstr = sprintf('results/images/%03d_time_F_F0_render3d', fn);
                            fig = figure('Color', cb, 'Position', [100, 100, 700, 300], 'Visible', 'off');
                            
                            subplot('Position', [0, 0, .857, 1]);
                            h = image(I1(:, :, :, 1));
                            axis image;
                            set(gca, 'Units', 'normalized', 'XTick', [], 'YTick', [])
                            if par.application
                                apn = 1;
                                ht = text('String', {sprintf('{\\color{yellow}%02d:%05.2f min}', 0, 0); ...
                                    sprintf('{\\color{yellow}x %d}', videoPlaySpeed); ...
                                    sprintf('{\\color[rgb]{%f %f %f}%s}', res(fn).ap_tcol(apn, :), res(fn).ap_tits{apn})}, ...
                                    'Units', 'normalized', 'Position', [.02, .98], 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
                            else
                                ht = text('String', {sprintf('%02d:%05.2f min', 0, 0); sprintf('x %d', videoPlaySpeed);}, 'Units', 'normalized', ...
                                    'Position', [.02, .98], 'Color', 'y', 'HorizontalAlignment', 'left', 'VerticalAlignment', 'top');
                            end
                            h1 = subplot('Position', [.87, .05, .05, .9]);
                            image(ibar.i_space, ibar.r_space, ibar.rgb_space);
                            axis tight;
                            set(h1, 'YAxisLocation', 'right', 'YDir', 'normal', 'Color', cb, 'XColor', cf, 'YColor', cf, 'XTick', []);
                            ylabel(ibar.label, 'Color', cf)
                            export_fig(sprintf('%s.png', chstr), '-q100', '-nocrop', fig);
                            t1 = output('3d Ca2+ rendering: preview image saved', whos, toc(tStart), t1);
                            
                            %if par.ParforProgress2;  %pfpm = ParforProgress2('writing 3d Ca2+ F_F0 movie (stripe mode)', N, 1, 0,1);end
                            writerobj = VideoWriter(sprintf('%s.mp4', chstr), 'MPEG-4');
                            writerobj.FrameRate = videoPlaySpeed * sz(end) / (60 * xt(end));
                            open(writerobj);
                            hh = myHardcopyFigureSet(fig, 3);
                            for n = 1:N
                                set(h, 'CData', I1(:, :, :, n))
                                if par.application
                                    apn = sum(n >= ap_times_frame(:, 1));
                                    set(ht, 'String', {sprintf('{\\color{yellow}%02d:%05.2f min}', floor(xt(n)), 60 * xt(n) - 60 * floor(xt(n))); ...
                                        sprintf('{\\color{yellow}x %d}', videoPlaySpeed); ...
                                        sprintf('{\\color[rgb]{%f %f %f}%s}', res(fn).ap_tcol(apn, :), res(fn).ap_tits{apn})});
                                else
                                    set(ht, 'String', {sprintf('%02d:%05.2f min', floor(xt(n)), 60 * xt(n) - 60 * floor(xt(n))); ...
                                        sprintf('x %d', videoPlaySpeed)})
                                end
                                A = myHardcopy(fig, hh, 3);
                                writeVideo(writerobj, A);
                                %if par.ParforProgress2; %pfpm.increment();end
                            end
                            %if par.ParforProgress2; %pfpm.delete();end
                            close(writerobj);
                            t1 = output('3d Ca2+ rendering: mp4 movie saved', whos, toc(tStart), t1);
                            %myHardcopyFigureReset(fig, hh);
                            system(sprintf('ffmpeg.exe -i %s.mp4 -vcodec libtheora -y %s.ogg -nostats -loglevel panic', chstr, chstr));
                            t1 = output('3d Ca2+ rendering: ogg movie saved', whos, toc(tStart), t1);
                            close(fig);
                            
                            clear fig A * h * ibar chstr ii I1 N sz1 trp RGBStack Rdbg rgb_ratio dbg d_pf
                            
                            t1 = output('temp data deleted', whos, toc(tStart), t1);
                            %end
                            
                        end
                    end
                end
            end % ~par.Ca2.gen
        end % ~par.ROIs_only
        if par.saveRes
            save(['results/res_all.mat'], 'res')
            save(['results/res_Events.mat'], 'Events')
            
        end
        % end% fn loop
        
        % clear ap
        
        %% UNN - cycle end
        % alpha_Area3D = alpha.Area3D
    end
    
    % end LoopA
    
    %%
    if par.FRET && par.Rtc == 1
        fprintf('n\t\tRt\t\tEfD\t\tEfA\t\txD\t\tAi\n')
        disp(num2str([(1:size(par.RtcSingle))', par.RtcSingle ./ repmat(par.RtcSingle(:, 5), [1, 5])]))
        disp('')
        disp(num2str(sum(par.RtcSingle(1:end, 1:4)) ./ repmat(sum(par.RtcSingle(1:end, 5)), [1, 4])))
    end
    
    t1 = output('>>>>>> DONE <<<<<<<<', whos, toc(tStart), t1);
    
end
import csv
import numpy as np
import matplotlib.pyplot as pp

def draw_activity_moments(mask_file_name, ids_i=[], ids_j=[], num_frames=169, frame_width=512, frame_height=512):
    mask = []
    with open(mask_file_name, 'r') as csvfile:
        activity_mask_reader = csv.reader(csvfile, delimiter=';')
        frame_idx = 0
        for row in activity_mask_reader:
            mask_frame = np.array([])
            mask_frame = np.hstack((mask_frame, row))
            for row_idx in range(frame_width - 1):
                mask_frame = np.vstack((mask_frame, next(activity_mask_reader)))
            mask.append(mask_frame)
            frame_idx = frame_idx + 1
            if (frame_idx >= num_frames):
                break
            # 2 empty lines between frames
            next(activity_mask_reader)
            next(activity_mask_reader)
    mask = np.asarray(mask)
    if len(ids_i) == 0:
        ids_i = range(frame_width)
    if len(ids_j) == 0:
        ids_j = range(frame_height)
    
    for i in ids_i:
        for j in ids_j:
            activity_moments = np.nonzero(mask[:, i, j].astype(int))
            print(activity_moments)
            val = i * frame_width + j
            pp.plot(activity_moments, np.zeros_like(activity_moments) + val, 'x')
    pp.show()
    

# Dooley_et_al._2020
Code used in Dooley et al., 2020. Published in Current Biology.

Scripts
* **Whisker_DLC_Import.m**
  * Imports whisker position from DeepLabCut output file (.csv) and calculates displacement as a function of time.
* **Whisker_Movement_Detection.m**
  * Uses the output from **Whisker_DLC_Import.m** to detect the onset of whisker movements.
* **Video_Change_Detection.m**
  * Detects frame-by-frame changes in pixel intensity within a user-defined region-of-interest (ROI). Designed to work with MJPEG videos. Select the desired video(s), then right-click to define up to 5 ROIs. The slider bar allows the user to view different frames, but will reset the selected ROIs.
* **Determine_Movement_Periods.m**
  * Uses the output from **Video_Change_Detection.m** to identify periods of movement and periods of non-movement.
* **Determine_Spindle_Bursts.m**
  * Detects spindle burst events within LFP data. Calculates spindle burst onset, amplitude, peak frequency, length, and number of cycles.

Dependencies
* **Video_File_Search.m** (required for **Video_Change_Detection.m**)
  * Searches file structure for videos to analyze.
* **ROI_Selector.m** (required for **Video_Change_Detection.m**)
  * GUI for selection of multiple regions-of-interest within a video frame.
* **Logical_Consecutive.m** (required for **Determine_Spindle_Bursts.m**)
  * Counts sequences of 0s and 1s within a logical matrix.
* **Spindle_Filter.m** (required for **Determine_Spindle_Bursts.m**)
  * Filters LFP data at spindle burst frequencies.

All code is written by Jimmy Dooley and Ryan Glanz.

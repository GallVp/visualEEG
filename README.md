# VisualEEG
VisualEEG is a MATLAB/GUIDE based toolbox which can be used for visual analysis of eeg data.

---

## Importing Data
visualEEG can only import data saved in **.mat** files. All the files should be stored in a single directory. Following naming scheme should be used for files.

> subXX_sessYY.mat

In each file, the data should be saved in **mydata** variable. This variable should have *channels* along *columns* and *samples* along *rows*.

There are two ways in which data can be imported.
> 1.  By trial time
* By epoch index

In method 1, only *trial time* and *sampling rate* are needed. In method 2, *sampling rate*, *time before epoch index* and *time after epoch index* are needed. In this case, each *.mat* file should also contain another variable **epoch_start**. This variable should be a vector whose length is equal to total number of trials.

---

## Changelog
###Version 1.0 *19/04/2016*
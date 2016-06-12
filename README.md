# VisualEEG
VisualEEG is a MATLAB/GUIDE based toolbox which can be used for visual analysis of eeg/emg data.

---

## Installation
Copy the **visualEEG** folder to **Matlab** folder. From Matlab file explorer add the folder to path by selecting the **Selected folders and subfolders** option. Run **visualEEG.fig** from **guide** tool.

---

## Importing Data
visualEEG can only import data saved in **.mat** files. All the files should be stored in a single directory. Following naming scheme should be used for files.

> subXX_sessYY.mat

In each file, the data should be saved in **EEGData** variable. This variable should have *channels* along *rows* and *samples* along *columns*.

There are three ways in which data can be imported.
> 1.  By epoch time
* By epoch event
* Signal mat files

In method 1, only *epoch time* and *sampling rate* are needed. In method 2, *sampling rate*, *time before epoch event* and *time after epoch event* are needed. In this case, each *.mat* file should also contain another variable **Epoch_start**. This variable should be a vector whose length is equal to total number of epochs. By method 3, mat fies exported from CED Signal program can be imported. In this case, the name of the data structure in the mat file should have the same name as that of the file.

---

## Adding New Operations
New operations can be added easily by implementing three steps in **eegOperations** class. 1) Adding the name of the operation to **AVAILABLE_OPERATIONS** property. 2) Implementing user interaction dialog boxes in **askArgs** function to acquire operation parameters. 3) Implementing the operation in **applyOperation** function.
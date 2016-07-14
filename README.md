# VisualEEG

[![Gitter](https://badges.gitter.im/usmanayubsh/visualEEG.svg)](https://gitter.im/usmanayubsh/visualEEG?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

VisualEEG is a MATLAB/GUIDE based toolbox which can be used for visual analysis of EEG/EMG/TMS data.

## Compatibility
Currently visualEEG is being developed on OSX El Capitan, MATLAB version R2015b. Windows/Linux users can experience some problems with the GUI layout.

## Installation

1. Clone the git repository.

    ```
    $ git clone --recursive https://github.com/GallVp/visualEEG
    ```

2. From MATLAB file explorer, add the folder/repository *visualEEG* to `path` by selecting the *Selected folders and subfolders* option. Run `visualEEG.m` file.

## Importing Data
visualEEG can only import data saved in `.mat` files. All the files should be stored in a single directory. Following naming scheme should be used for files.

`subXX_sessYY.mat`

There are three ways in which data can be imported.

1. By epoch time
2. By epoch event
3. Signal mat files

In method 1, only *epoch time* and *sampling rate* are needed. In method 2, *sampling rate*, *time before epoch event* and *time after epoch event* are needed. In this case, each `.mat` file should also contain another vector variable for event information. This variable should be a vector whose length is equal to total number of epochs. By method 3, mat fies exported from CED Signal program can be imported.

## Sample Data
*Sample Data* folder contains EEG data for two subjects with 4 sessions each. This data was recorded using Emotiv Epoc. Each session contains 25 to 35 trials. The sampling rate is *128 Hz*. The EEG data variable name is `EEGdata`. The length of each trail/epoch is 14 seconds. This data can be imported in visualEEG using default settings and *By epoch time* import method.

## Channel Naming
This feature is optional. If channel naming is required, a `.xls` file should be placed in the data directory. This spreadsheet should have two columns. First column containing channel numbers, while the second column containing channel names.

## Implementing New Operations
New operations can be implemented easily in visualEEG by carrying out three steps in    `eegOperations` class.

1. Adding the name of the operation to `AVAILABLE_OPERATIONS` property.
2. Implementing user interaction dialog boxes in `askArgs` function to acquire operation parameters.
3. Implementing the operation in `applyOperation` function.
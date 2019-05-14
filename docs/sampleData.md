# Sample Data Explained

## Contents:

<ul>
    <li>
        <a href="https://github.com/GallVp/visualEEG/tree/master/docs/README.md">Overview of visualEEG</a>
    </li>
    <li>
        <a href="https://github.com/GallVp/visualEEG/tree/master/docs/importData.md">How to Import Data in visualEEG?</a>
    </li>
    <li>
        <a href="https://github.com/GallVp/visualEEG/tree/master/docs/newOperations.md">How to Add New Operations?</a>
    </li>
</ul>

## Sample Data

A sample dataset is included with visualEEG source code. It is a single *MAT* file named *dorsiflexions.mat*. This file contains EEG and EMG data recorded continuously from a healthy participant doing right foot ballistic dorsiflexions at their own pace. The sample rate for both EEG and EMG data is 250 samples/sec.

### EEG Data

The EEG data was recorded from following international 10-20 system locations: FC3, FCz, FC4, C3, Cz, C4, P3, Pz, and P4. The reference was placed on the right mastoid. The data is stored in *eegData* variable.

### EMG Data

The EMG data was recorded from two electrodes placed next to each other on the Tibialis anterior muscle of the right leg. Their reference was also the right mastoid. Subsequently, the data from these two electrodes was combined by subtraction. Thus, the sample data file contains only one EMG channel. The data is stored in *emgData* variable. The EMG data was further processed to detect onsets which are stored in *emgOnsets* variable.
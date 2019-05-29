# libMRCP

A small library of functions to process movement-related cortical potentials.

## Topics

### 1. Automated Labeling of Movement-Related Cortical Potentials using Segmented Regression

#### DOI: [10.1109/TNSRE.2019.2913880](http://dx.doi.org/10.1109/TNSRE.2019.2913880)

#### Summary

This study proposes segmented regression along with a local peak method for automated labelling of the features. The proposed method derives the onsets, amplitudes at onsets and slopes of BP1, BP2 along with time and amplitude of the negative peak in a typical average MRCP. The proposed method can be used to automatically obtain robust estimates for these MRCP features with known measurement error.

#### Functions

1. `findMRCPFeat`: This function finds the onsets of BP1, BP2 and time of PN with respect to the movement onset, amplitudes at these time points, and slopes for BP1 and BP2.

2. `mrcpBSR`: Performs bounded segmented regression for mrcp segments using particle swarm optimisation. This function is called by `findMRCPFeat`.

#### Example

An example averaged MRCP is available in the *Sample Data/dorsiflexions_MRCP.mat* file. This averaged MRCP was obtained from averaging of EEG activity over fifty right foot ballistic dorsiflexions performed by a healthy person. It has the following variables:

```MATLAB
averagedMRCP:       % MRCP signal
fs:                 % Sample-rate
movementOnsetAt:    % Time of the movement onset in seconds.
```

Running the `findMRCPFeat(averagedMRCP, fs, movementOnsetAt)` gives following output.

<p align="center">
<img alt="Automated labelling example" src="../../docs/figs/findMRCPFeat_example.png" height="auto" width="50%"/><hr>
<em>Fig 1. Automated labeling of an example MRCP.</em>
</p>

If `findMRCPFeat` is ran with output arguments, it also returns the onsets BP1, BP2, time of PN, amplitudes at these time points and slopes of BP1 and BP2. For example:

```MATLAB
[timeVect, ampVect, slpVect, intVect, mdlResid] = findMRCPFeat(averagedMRCP, fs, movementOnsetAt);
```

Returns:

```MATLAB
timeVect =
   -2.2040      % Onset of BP1 (s)
   -0.5800      % Onset of BP2 (s)
    0.0920      % Time of PN (s)

ampVect =
    3.0343      % Amplitude at onset of BP1 (uV)
   -1.4920      % Amplitude at onset of BP2 (uV)
  -10.4032      % Amplitude at time of PN (uV)

slpVect =
       NaN
   -2.6502      % BP1 Slope (uV/s)
  -13.8593      % BP2 Slope (uV/s)
```

Note that the onset times are computed with respect to the movement onset.
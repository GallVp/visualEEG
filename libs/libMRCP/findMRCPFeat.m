function [timeVect, ampVect, slpVect, intVect, mdlResid] = findMRCPFeat(mrcpAsVect, fs, timeBeforeEvent)
%findMRCPFeat This function finds the onsets of BP1, BP2 and time of PN
%   with respect to the movement onset, amplitudes at these time points,
%   and slopes for BP1 and BP2.
%
%   Inputs:
%   1. mrcpAsVect: MRCP signal as vector. Signal amplitude is assumed to be
%      in micro-volts (uV).
%   2. fs: Sample-rate
%   3. timeBeforeEvent: Epoch length before the event in seconds.
%
%   Outputs:
%   1. timeVect: Time of BP1, BP2 and PN in seconds with respect to the 
%      time of the event in mrcpAsVect.
%   2. ampVect: Amplitudes at the onsets of BP1, BP2 and time of the PN.
%      For BP1, BP2 these amplitudes are taken from the fitted model. For
%      the PN, it is taken from the signal (mrcpAsVect).
%   3. slpVect: Model slopes in uV/second.
%   4. intVect: Model intercepts in uV.
%   5. mdlResid: Model residuals
%
%   Abbreviations:
%   MRCP: Movement-related cortical potential
%   BP1: Early bereitschaftspotential
%   BP2: Late bereitschaftspotential
%   PN: Negative peak
%
%   Copyright (c) <2018> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

% Convert data to column form, if matrix throw error
if size(mrcpAsVect, 2) > 1
    mrcpAsVect = mrcpAsVect';
    if(size(mrcpAsVect, 2)) > 1
        error('Only vector mrcpAsVect allowed...');
    end
end

%% Constants
PN_WINDOW           = [-1 1]; % In seconds wrt event
BP1_BOUNDS          = [timeBeforeEvent - 2.5 timeBeforeEvent - 1] * fs;
BP2_BOUNDS          = [timeBeforeEvent - 1 timeBeforeEvent + 1] * fs;

%% Step I; Find PN time and amplitude, using findpeaks method.
pnWindow            = (PN_WINDOW + timeBeforeEvent) * fs;
[pnValue, pnSample] = findpeaks(-mrcpAsVect(pnWindow(1)+1:pnWindow(2)), 'SortStr', 'descend', 'NPeaks', 1);
if(isempty(pnSample))
    error('findMRCPFeat: Could not find the negative peak (PN)...');
end
pnValue             = -pnValue;
pnSample            = pnSample + pnWindow(1);

%% Step II: Use data upto pnSample to find BP1 and BP2, using bounded segmented regression (BSR)
regressionData      = mrcpAsVect(1:pnSample);
[pointA, pointB]    = mrcpBSR(regressionData, BP1_BOUNDS, BP2_BOUNDS);
bsrBP1Sample        = pointA;
bsrBP2Sample        = pointB;

modelBSR            = buildModel(mrcpAsVect, [bsrBP1Sample; bsrBP2Sample; pnSample]);


mdlResid            = modelBSR.error;
sampleVect          = modelBSR.sampVect;
intVect             = modelBSR.intVect;
slpVect             = modelBSR.slpVect;
timeVect            = sampleVect ./fs - timeBeforeEvent;

% Amplitudes vector
ampVect             = [intVect(1); intVect(2) + slpVect(2)*sampleVect(2); pnValue];

% Convert slope to uV/second
slpVect             = slpVect .* fs;

% Plot data if output arguments absent
if nargout < 1
    tVect = (1:length(mrcpAsVect)) ./fs - timeBeforeEvent;
    plot(tVect, mrcpAsVect);
    hold on;
    axInfo = axis;
    % Plot lines from model
    plot([timeVect(1) timeVect(1)], [axInfo(3) axInfo(4)], 'k--');
    plot([timeVect(2) timeVect(2)], [axInfo(3) axInfo(4)], 'm-.');
    plot(timeVect(3), ampVect(3), 'ko', 'MarkerSize', 8);
    plot([tVect(1) timeVect(1)], [intVect(1) intVect(1)], 'r--');
    plot([timeVect(1) timeVect(2)], [intVect(2) + slpVect(2)*(timeVect(1) + timeBeforeEvent) ampVect(2)], 'r--');
    plot([timeVect(2) timeVect(3)], [intVect(3) + slpVect(3)*(timeVect(2) + timeBeforeEvent) intVect(3) + slpVect(3)*(timeVect(3) + timeBeforeEvent)], 'r--');
    hold off;
    xlabel('Time (s)');
    ylabel('Amplitude (uV)');
    legend({'MRCP signal', 'BP1 onset', 'BP2 onset', 'PN', 'Fitted model'}, 'Location', 'southeast', 'Box', 'off');
    box off;
end

    function model = buildModel(mrcpData, sampVect)
        model.sampVect          = sampVect;
        % Using the sampVect, get data segments
        baselineSegment         = mrcpData(1:sampVect(1));
        bp1Segment              = mrcpData(sampVect(1)+1: sampVect(2));
        bp2Segment              = mrcpData(sampVect(2)+1: sampVect(3));
        % Obtain the fitted model
        abscissa                = (1:length(mrcpData))';
        baselineModel           = [NaN mean(baselineSegment)];
        bp1Model                = [abscissa(sampVect(1)+1 : sampVect(2)) ones(length(bp1Segment), 1)] \ bp1Segment;
        b2Model                 = [abscissa(sampVect(2)+1 : sampVect(3)) ones(length(bp2Segment), 1)] \ bp2Segment;
        % Return samples, amplitudes, slopes, intercepts and residuals.
        model.intVect   = [baselineModel(2);bp1Model(2);b2Model(2)];
        model.slpVect   = [baselineModel(1);bp1Model(1);b2Model(1)];
        outputSegOne    = model.intVect(1) .* ones(length(baselineSegment), 1);
        outputSegTwo    = model.intVect(2) + model.slpVect(2) .* (sampVect(1)+1:sampVect(2))';
        outputSegThree  = model.intVect(3) + model.slpVect(3) .* (sampVect(2)+1:sampVect(3))';
        model.output    = [outputSegOne;outputSegTwo;outputSegThree];
        model.error     = model.output - mrcpData(1: sampVect(3));
    end
end
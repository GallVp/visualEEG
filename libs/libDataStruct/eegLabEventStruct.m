function [ eventStruct ] = eegLabEventStruct( forEventVect, eventType )
%eegLabEventStruct Takes an event times vector and returns a eeglab
%   compatible event structure.
%
%   Copyright (c) <2016> <Usman Rashid>
%   Licensed under the MIT License. See License.txt in the project root for
%   license information.

if isempty(forEventVect)
    eventStruct = struct([]);
    return;
end

numEvents = length(forEventVect);
eventStruct = struct([]);

for eventNum = 1:numEvents
    if iscell(eventType) && length(eventType) ~= 1
        eventStruct(eventNum).('type') = eventType(eventNum);
    else
        eventStruct(eventNum).('type') = eventType;
    end
    eventStruct(eventNum).('latency') = forEventVect(eventNum);
    eventStruct(eventNum).('duration') = 1; % Number of samples
    eventStruct(eventNum).('urevent') = eventNum;
end

end
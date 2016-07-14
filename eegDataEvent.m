classdef (ConstructOnLoad) eegDataEvent < event.EventData
    
    
    % Copyright (c) <2016> <Usman Rashid>
    %
    % This program is free software; you can redistribute it and/or
    % modify it under the terms of the GNU General Public License as
    % published by the Free Software Foundation; either version 2 of the
    % License, or (at your option) any later version.  See the file
    % LICENSE included with this distribution for more information.
    
    
    properties
        changeName = '';
    end
    methods
        function eventData = eegDataEvent(name)
            eventData.changeName = name;
        end
    end
end
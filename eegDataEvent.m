classdef (ConstructOnLoad) eegDataEvent < event.EventData
   properties
      changeName = '';
   end
   methods
      function eventData = eegDataEvent(name)
         eventData.changeName = name;
      end
   end
end
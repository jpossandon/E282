% Basic trial

% Button press or finger in starting position for at least x ms
% visual signal that indicates the target would appear
% random ISI
% tactile stimulation
% movement period
% trial end either when:
% 1 - finger is at one of the target location
%     feedback correct-incorrect with light
% 2 - movement inititation reaction time is to slow
%     another feedback with light
% Light indicates trial ended and finger needs to go back to start position
% Transform C#00 file to matlab, erase C#00
% output:
%     initiation and reach reaction time

%Initialize a file for spooling of the OPTOTRAK data.
tic,optotrak('DataBufferInitializeFile',{'OPTOTRAK'},sprintf('R#00_s%02_dt%03d.DAT',suj,nT));
toc

% is finger on place
minnum_samples  = 20;
posfields           = fields(exp.pos);                                      % check all fields that are not radius      
while cont_flag                                                             % we continue checking the data until all the position have been verified
    data    = optotrak('DataGetNext3D',exp.coll.NumMarkers);                      
    curdata = cell2mat(data.Markers')';
    
    pause(.05)
    if hypot(curdata(1,1)-exp.pos.(posfields{nTarget})(1),...            % when the distance to the center of the target position is less than radius we add to a counter
       curdata(1,2)-exp.pos.(posfields{nTarget})(2))<exp.pos.radius
        there = there+1;
    else                                                                   % and flush the counter if the marker to target distance is more than 1
        there = 0;
    end
    if there>minnum_samples                                                % when the counter is above the minimun number of sample we move to the next target position
        cont_flag = cont_flag+1;
    end
end

% start light
tstart
%Start the OPTOTRAK spooling data to us.
optotrak('DataBufferStart');    

%Loop around spooling data
SpoolComplete=0;
while ~SpoolComplete
    %Write data if there is any to write.
    [RealtimeDataReady,SpoolComplete,SpoolStatus,FramesBuffered] = optotrak('DataBufferWriteData');
    %disp(['DataBufferWriteData: ' num2str(RealtimeDataReady) ' ' num2str(SpoolComplete) ' ' num2str(SpoolStatus) ' ' num2str(FramesBuffered)]);
    
    % check for position and reaction time to move
    % check for position on target
    if(RealtimeDataReady)
        %Receive the 3D data.
        data=optotrak('DataReceiveLatest3D',coll.NumMarkers);
        %Print out the data.
        fprintf('Frame Number: %8u\n',data.FrameNumber);
        fprintf('Elements    : %8u\n',data.NumMarkers);
        fprintf('Flags       : 0x%04x\n',data.Flags);
        for MarkerCnt = 1:coll.NumMarkers
          fprintf('Marker %u X %8.2f Y %8.2f Z %8.2f\n', MarkerCnt,...
                  data.Markers{MarkerCnt}(1),...
                  data.Markers{MarkerCnt}(2),...
                  data.Markers{MarkerCnt}(3))
        end
    end
  end
% 
%     optotrak('DataBufferStop');
    
optotrak('FileConvert',sprintf('s%02dt%03d.DAT',suj,nT),['C#00',num2str(nt),'.DAT'],{'OPTOTRAK_RAW'});
odata=optotrak('Read3DFileWithRigidsToMatlab',['data_trial',num2str(trial),'.PC3D'],epar.NumRigids);
  %...and save those as MAT file:
  save(['data_trial',num2str(trial),'.mat'],'odata','-mat');

fprintf('Spooling took: %d seconds\n', toc);
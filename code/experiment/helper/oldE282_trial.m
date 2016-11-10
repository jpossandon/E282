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
%
% - Triggers parallel:
%    - 1 - left uncrossed
%    - 2 - right uncrossed
%    - 5 - left crossed
%    - 6 - right crossed

% initialize a file for spooling of the OPTOTRAK data.
%  optotrak('OptotrakActivateMarkers')                                         % activate the markers.

optotrak('DataBufferInitializeFile',{'OPTOTRAK'},...
    sprintf('%s%s%02d%sR#00_s%s_dt%03d.DAT',...
    exp.Spath,filesep,result.trial_block(next_trial),filesep,exp.sNstr,next_trial));
 display(sprintf(...
            '\nTRIAL #%d\n waiting for subject to go to start position',next_trial))
% buffer the start beep sound
PsychPortAudio('FillBuffer', pahandle, [wave.stBeep ; wave.stBeep]);

% is the finger at start location?
t1                  = GetSecs;       
minnum_samples      = 20;
onTarget            = 0;

while ~onTarget                                                             % we continue checking the data until all the position have been verified
    datac    = optotrak('DataGetNext3D',exp.coll.NumMarkers);                      
    curdata = cell2mat(datac.Markers')';
    
 %   pause(.05)
    if hypot(curdata(1,1)-exp.pos.origen(1),...                              % when the distance to the center of the target position is less than radius we add to a counter
       curdata(1,2)-exp.pos.origen(2))<exp.pos.radius
        there = there+1;
    else                                                                    % and flush the counter if the marker to target distance is more than 1
        there = 0;
    end
    if there>minnum_samples                                                 % when the counter is above the minimun number of sample we can start the experiment
        onTarget    = 1;
    end
    if GetSecs-t1>5
        display(sprintf(...
            '\nWe cannot start next trial,\n subject finger is not at the start position\n'))
        t1                  = GetSecs;       
    end
end

optotrak('DataBufferStart');tic                                                % start the OPTOTRAK spooling data to us. Here we are using Advanced Buffered Data Retrieval Without Blocking
t1 = PsychPortAudio('Start', pahandle, 1, 0, 0);               % start beep
t2 = GetSecs;
WaitSecs(.05);                                                              % so there is no problem with the start sound
PsychPortAudio('FillBuffer', pahandle, [ wave.tact;zeros(1,length(wave.tact))]);            % buffer the sound that drives tactile stimulation
PsychPortAudio('Start', pahandle, 1, 0, 0); 
stim_delivered  = 0;                                                        % flag to know wheter a stimulus have been delivered
too_late        = 0;                                                        % flag to know wheter subject have taken more than the trial required time    
onLeft          = 0;        onRight = 0;
trial_ready     = 0;
outOrigen       = 0;
buffer_stop     = 0; 

start_audio=0;
% Loop around spooling data
SpoolComplete=0;
%a=1;
while ~SpoolComplete
    
    [RealtimeDataReady,SpoolComplete,SpoolStatus,FramesBuffered] = ...      % this need to be called repeteadly so buffered data can be written in the experimental computer
        optotrak('DataBufferWriteData');
%FramesBuffered
    if ~stim_delivered                                                      % here we deliver stimulus when the soa has elapsed
        t3 = GetSecs;
%          if t3-t2>(exp.soa_fix/2)/1000 & ~start_audio
%              PsychPortAudio('Start', pahandle, 1, 0, 0);
%              start_audio = 1
%          end
        if t3-t2>result.soa(next_trial)/1000
           stimFrame = data.FrameNumber;
           % deliver stimulus, the next trhee lines takes in average 64.3
           % ms (SD = 6.8 ms) (measured 30.09.2016)
           putvalue(DIO.line(1:8),dec2binvec(result.trial_trigger(next_trial),8));                                        % this is via the nidaq card
           WaitSecs(.025);
           putvalue(DIO.line(1:8),dec2binvec(0,8));  
%           parallelTrigger(result.trial_trigger(next_trial),pObj_handle)
           stim_delivered = 1
           PsychPortAudio('Stop', pahandle, 1, 0, 0);
        %   toc
        end
    end
    
    %TODO: too soon
    % check for position on either target position
  %  if(RealtimeDataReady)
 %       data        = optotrak('DataReceiveLatestTransforms',exp.coll.NumMarkers,0),             % Receive the 3D data.
     data        = optotrak('DataGetNext3D',exp.coll.NumMarkers);%toc             % Receive the 3D data.
    % datas(a) = data; a = a+1;
     curdata     = cell2mat(data.Markers')';
        if hypot(curdata(1,1)-exp.pos.origen(1),...                              
            curdata(1,2)-exp.pos.origen(2))>exp.pos.radius  
            onTarget        = 0
            if stim_delivered && ~outOrigen
                result.moveRT(next_trial)   = (data.FrameNumber-stimFrame)./exp.coll.FrameFrequency; %GetSecs-t3;
                outOrigen       = 1;
            end
        end   
        if hypot(curdata(1,1)-exp.pos.left(1),...                              
            curdata(1,2)-exp.pos.left(2))<exp.pos.radius
            onLeft      = 1
       end
       if hypot(curdata(1,1)-exp.pos.right(1),...                              
            curdata(1,2)-exp.pos.right(2))<exp.pos.radius  
            onRight     = 1
       end
       
   % end
    
    if (onLeft || onRight) && ~trial_ready && stim_delivered 
        result.reachRT(next_trial)   = (data.FrameNumber-stimFrame)./exp.coll.FrameFrequency;
        if ~too_late
            PsychPortAudio('FillBuffer',...                                     
                pahandle, [wave.reachBeep ; wave.reachBeep]);
            PsychPortAudio('Start', pahandle, 1, 0, 0);                         % on target beep
        end
        trial_ready = 1    
    end
    
    if stim_delivered && ~trial_ready && ~too_late && onTarget                                                                                                      
        if  (data.FrameNumber-stimFrame)./exp.coll.FrameFrequency>result.trial_maxRT(next_trial)/1000 
            PsychPortAudio('FillBuffer',...                                     
                pahandle, [wave.lateBeep ; wave.lateBeep]);
            too_late    = 1
        end
    end
    
%     if trial_ready %&& ~buffer_stop             % data buffer stop does
% %    not work well udnfortunately
% %         WaitSecs(.250);
%          optotrak('DataBufferStop');                                         % this still need repeated call of databufferwritedata
%          buffer_stop = 1
% else
%       optotrak('RequestLatestTransforms')
%    end
   
end
toc
% optotrak('DataBufferStop'); 
if too_late     
   PsychPortAudio('Start', pahandle, 1, 0, 0);
end
result.stimFrame(next_trial) = stimFrame;
% while(~optotrak('DataIsReady'))
%     fprintf('Data not ready yet\n');
% end
% was it correct
if onLeft && (result.trial_trigger(next_trial)==1 || result.trial_trigger(next_trial)==6) ...
        || (onRight && (result.trial_trigger(next_trial)==2 || result.trial_trigger(next_trial)==5)) 
    result.correct(next_trial) = 1;
elseif  (onLeft && (result.trial_trigger(next_trial)==2 || result.trial_trigger(next_trial)==5)) ...
        || (onRight && (result.trial_trigger(next_trial)==1 || result.trial_trigger(next_trial)==6))
    result.correct(next_trial) = 0;
else
    result.correct(next_trial) = NaN;
    result.reachRT(next_trial) = NaN;
end
% Checking RT
if ~outOrigen
     result.moveRT(next_trial) = NaN;
end
%   
%optotrak('OptotrakPrintStatus')
optotrak('FileConvert',...
    sprintf('%s%s%02d%sR#00_s%s_dt%03d.DAT',exp.Spath,filesep,result.trial_block(next_trial),filesep,exp.sNstr,next_trial),...
sprintf('%s%s%02d%sC#00_s%s_dt%03d.DAT',exp.Spath,filesep,result.trial_block(next_trial),filesep,exp.sNstr,next_trial),{'OPTOTRAK_RAW'});

%optotrak('OptotrakDeActivateMarkers')
% odata(next_trial)=optotrak('Read3DFileWithRigidsToMatlab',sprintf('%s%s%02d%sC#00_s%s_dt%03d.DAT',exp.Spath,filesep,result.trial_block(next_trial),filesep,exp.sNstr,next_trial),0);
 % if we got the data, we are happy
result.trial_done(next_trial) = 1;
next_trial = next_trial+1;   
%...and save those as MAT file:
%  save(['data_trial',num2str(trial),'.mat'],'odata','-mat');
save(sprintf('%s%ss%s_results.mat',exp.Spath,filesep,exp.sNstr),'result')

%
% Trial sequence fix

% Finger in starting position for at least x ms
% sequence of auditory signal indicates to initiate a movement within 75 ms
% of the fourth tone
% tactile stimulation between third and fourth tone at random times
% trial end either when:
% 1 - finger is at one of the target location
%     feedback correct-incorrect with light
% 2 - movement inititation reaction time is to slow
%     another feedback with light
% tome indicates trial ended and finger needs to go back to start position
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
% PsychPortAudio('FillBuffer', pahandle, [wave.stBeep ; wave.stBeep]);

% this is the tactile file specific for this trial
wavetact        = sin(2.*pi.*exp.sound.tact_freq.*...               % the tactile stimulus
                         [0:1/exp.sound.fs:exp.sound.tactile_dur-1/exp.sound.fs]); 
% wavetact        = wavetact.*fliplr([0:1/exp.sound.fs/result.trial_maxRT(next_trial):1-1/exp.sound.fs/result.trial_maxRT(next_trial)]);
wave.seq(1,4*exp.sound.seqBeeps_time*exp.sound.fs-result.soa(next_trial)*exp.sound.fs:4*exp.sound.seqBeeps_time*exp.sound.fs-result.soa(next_trial)*exp.sound.fs+length(wavetact)-1) = wavetact;
PsychPortAudio('FillBuffer', pahandle, wave.seq);
wave.seq(1,:) =0;
% is the finger at start location?
t1                  = GetSecs;       
minnum_samples      = 20;
onTarget            = 0;

while ~onTarget                                                             % we continue checking the data until all the position have been verified
    datac    = optotrak('DataGetNext3D',exp.coll.NumMarkers);                      
    curdata = cell2mat(datac.Markers')';
    
 %   pause(.05)
    if hypot(curdata(1,1)-exp.pos.origen(1),...                              % when the distance to the center of the target position is less than radius we add to a counter
       curdata(1,2)-exp.pos.origen(2))<exp.pos.radius/2
        there = there+1;
    else                                                                    % and flush the counter if the marker to target distance is more than 1
        there = 0;
    end
    if there>minnum_samples                                                 % when the counter is above the minimun number of sample we can start the experiment
        onTarget    = 1;
    end
    if GetSecs-t1>15
        display(sprintf(...
            '\nWe cannot start next trial,\n subject finger is not at the start position\n'))
        t1                  = GetSecs;       
    end
end
optotrak('DataBufferStart');tic                                                     % start the OPTOTRAK spooling data to us. Here we are using Advanced Buffered Data Retrieval Without Blocking
fixt = .5;
t0 = GetSecs;
PsychPortAudio('Start', pahandle, 1, t0+fixt, 0);                                % start beep, every start takes aprox .5 s, here last input is 0 so software continues although sound has not been reproduced, start time should be t0+fixt (checked latencies on 30.11.2016), given that fixt is greater than .5 (for this setup)

% PsychPortAudio('FillBuffer', pahandle, [ wavetact;zeros(1,length(wavetact))]);    % buffer the sound that drives tactile stimulation, this takes aprox< 1 ms
% PsychPortAudio('Start', pahandle, 1, t2+result.soa(next_trial), 0); 
%  status = PsychPortAudio('GetStatus',pahandle),toc
putvalue(DIO.line(1:8),dec2binvec(result.trial_trigger(next_trial),8));     % stimulation channel is on during the complete trial

stim_delivered  = 0;                                                        % flag to know wheter a stimulus have been delivered
too_late        = 0;                                                        % flag to know wheter subject have taken more than the trial required time    
too_early       = 0;
onLeft          = 0;        onRight = 0;
trial_ready     = 0;
outOrigen       = 0;
moved           = 0;
reached         = 0;

% Loop around spooling data
SpoolComplete=0;
%a=1;
while ~SpoolComplete
    
    [RealtimeDataReady,SpoolComplete,SpoolStatus,FramesBuffered] = ...      % this need to be called repeteadly so buffered data can be written in the experimental computer
        optotrak('DataBufferWriteData');
%FramesBufferedtoc
    if ~stim_delivered                                                      % this is time counting, the sofware is unable to knwo when the audio starts, this was measured that worked precisllz for SOA >500
    	t3 = GetSecs;
        if t3-t0>exp.sound.seqBeeps_time*4-result.soa(next_trial)+fixt                                       
        stimFrame = data.FrameNumber;                                       
        stim_delivered = 1;
        end
    end

    % check for position on either target position
    data        = optotrak('DataGetNext3D',exp.coll.NumMarkers);%toc             % Receive the 3D data.
    curdata     = cell2mat(data.Markers')';
    if hypot(curdata(1,1)-exp.pos.origen(1),...                              
        curdata(1,2)-exp.pos.origen(2))>exp.pos.radius/2 && onTarget 
        onTarget        = 0;
        outOrigen       = 1;
        moveFrame       = data.FrameNumber;
        tmov            = GetSecs;
        result.fixmoveRT(next_trial) = tmov-(t0+exp.sound.seqBeeps_time*4+fixt);
    end   
    if hypot(curdata(1,1)-exp.pos.left(1),...                              
        curdata(1,2)-exp.pos.left(2))<exp.pos.radius && ~onLeft
        onLeft          = 1;
        leftFrame       = data.FrameNumber;
    end
    if hypot(curdata(1,1)-exp.pos.right(1),...                              
        curdata(1,2)-exp.pos.right(2))<exp.pos.radius && ~onRight
        onRight         = 1;
        rightFrame      = data.FrameNumber;
    end
    
    % when movement occurs before the last beep is too early
    if ~too_early && outOrigen && GetSecs<t0+exp.sound.seqBeeps_time*4+fixt                                                                                               
%         earlymoveFrame = data.FrameNumber; 
        display(sprintf('%4.2f s to last beep, TOO EARLY',GetSecs-(t0+exp.sound.seqBeeps_time*4+fixt)))
        too_early    = 1;
    end 
    
    % when movement occurs after trial_maxRT form the last beep is too late
    if ~too_late && onTarget &&  GetSecs>t0+exp.sound.seqBeeps_time*4+fixt+result.trial_maxRT(next_trial)                                                                                                      
       PsychPortAudio('Stop', pahandle);
       PsychPortAudio('FillBuffer',...                                     
            pahandle, [wave.lateBeep ; wave.lateBeep]);
       PsychPortAudio('Start', pahandle, 1, t0+exp.sound.seq_dur, 0);
       too_late    = 1;
    end
    
    if (too_early && stim_delivered && ~moved) || (~too_early && outOrigen && ~moved)
        result.moveRT(next_trial)   = (moveFrame-stimFrame)./exp.coll.FrameFrequency;
        moved = 1;
    end
    
    if (too_early && stim_delivered && (onLeft || onRight) && ~reached) || (~too_early && stim_delivered && (onLeft || onRight) && ~reached)
        if onLeft
            result.reachRT(next_trial)   = (leftFrame-stimFrame)./exp.coll.FrameFrequency;
        elseif onRight
            result.reachRT(next_trial)   = (rightFrame-stimFrame)./exp.coll.FrameFrequency;
        end
        if ~too_early && ~too_late
            PsychPortAudio('Stop', pahandle);
            PsychPortAudio('FillBuffer',...                                     
                pahandle, [wave.reachBeep ; wave.reachBeep]);
            PsychPortAudio('Start', pahandle, 1, t0+exp.sound.seq_dur, 0);                         % on target beep
        end
        reached =1;
    end
       
    if too_early  &&  GetSecs>t0+exp.sound.seqBeeps_time*4+fixt
       PsychPortAudio('Stop', pahandle);
       PsychPortAudio('FillBuffer',...                                     
           pahandle, [wave.earlyBeep ; wave.earlyBeep]);
       PsychPortAudio('Start', pahandle, 1, t0+exp.sound.seq_dur, 0);
    end
end
putvalue(DIO.line(1:8),dec2binvec(0,8));  
result.stimFrame(next_trial) = stimFrame;
if outOrigen
    result.moveFrame(next_trial) = moveFrame;
end
if too_late && onTarget
    display('Subject did not move, TOO LATE')
elseif too_late && outOrigen
    display(sprintf('%4.2f s after fourth Beep, TOO LATE', tmov-(t0+exp.sound.seqBeeps_time*4+fixt)))
end  
% was it correct
if (onLeft && (result.trial_trigger(next_trial)==1 || result.trial_trigger(next_trial)==6)) ...
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
if outOrigen
    result.moveFrame(next_trial) = moveFrame;
else
    result.moveRT(next_trial)   = NaN;
    result.moveFrame(next_trial)= NaN; 
end
%   
%optotrak('OptotrakPrintStatus')
optotrak('FileConvert',...
    sprintf('%s%s%02d%sR#00_s%s_dt%03d.DAT',exp.Spath,filesep,result.trial_block(next_trial),filesep,exp.sNstr,next_trial),...
sprintf('%s%s%02d%sC#00_s%s_dt%03d.DAT',exp.Spath,filesep,result.trial_block(next_trial),filesep,exp.sNstr,next_trial),{'OPTOTRAK_RAW'});

%optotrak('OptotrakDeActivateMarkers')
 odata(next_trial)=optotrak('Read3DFileWithRigidsToMatlab',sprintf('%s%s%02d%sC#00_s%s_dt%03d.DAT',exp.Spath,filesep,result.trial_block(next_trial),filesep,exp.sNstr,next_trial),0);
 % if we got the data, we are happy
result.trial_done(next_trial) = 1;
next_trial = next_trial+1;   
%...and save those as MAT file:
%  save(['data_trial',num2str(trial),'.mat'],'odata','-mat');
save(sprintf('%s%ss%s_%s_results.mat',exp.Spath,filesep,exp.sNstr,sTtyp),'result')
clear stimFrame earlymoveFrame

%
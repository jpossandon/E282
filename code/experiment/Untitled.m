
PsychPortAudio('Start', pahandle, 1, 0, 0);
 WaitSecs(.6);
t1 = GetSecs; 
putvalue(DIO.line(1:8),dec2binvec(result.trial_trigger(next_trial),8));                                        % this is via the nidaq card
    
 while GetSecs-t1<result.trial_maxRT(next_trial)/1000
     nnt = GetSecs-t1
      newvol = ((result.trial_maxRT(next_trial)/1000)-(GetSecs-t1))/(result.trial_maxRT(next_trial)/1000)
      [old]= PsychPortAudio('Volume',pahandle,newvol)
 end
 putvalue(DIO.line(1:8),dec2binvec(0,8));  
      PsychPortAudio('Volume', pahandle,1);
      result.trial_maxRT
      
      max
exp.sound.tactile_dur       = result.trial_maxRT(next_trial);%result.trial_maxRT(next_trial);                                                % tactile stimulation sinosouidal sound duration
tic
wave.tact                   = sin(2.*pi.*exp.sound.tact_freq.*...               % the tactile stimulus
                         [0:1/exp.sound.fs:exp.sound.tactile_dur-1/exp.sound.fs]);  
 wave.tact = wave.tact.*fliplr([0:1/exp.sound.fs/result.trial_maxRT(next_trial):1-1/exp.sound.fs/result.trial_maxRT(next_trial)])
PsychPortAudio('FillBuffer', pahandle, [ wave.tact;zeros(1,length(wave.tact))]);            % buffer the sound that drives tactile stimulation
toc

t1=GetSecs;st = PsychPortAudio('Start', pahandle, 1, t1+.7, 0);st-t1 PsychPortAudio('GetStatus',pahandle)


tic
PsychPortAudio('FillBuffer', pahandle, [wave.stBeep ; wave.stBeep]);
t0 = GetSecs;
t2 = PsychPortAudio('Start', pahandle, 1, t0+.5, 1);                                % start beep everz start takes aprox .5 s, here las input is 1 so we do not start until the sound is reproduced, t2 is when the sound start, whcih should be t0+.5

PsychPortAudio('FillBuffer', pahandle, [ wavetact;zeros(1,length(wavetact))]);    % buffer the sound that drives tactile stimulation, this takes aprox< 1 ms
PsychPortAudio('Start', pahandle, 1, t2+.2, 0); 
%  status = PsychPortAudio('GetStatus',pahandle),toc
while 1
 status = PsychPortAudio('GetStatus',pahandle),toc
 if status.Active
     
     break
 end
end
     
trial =15
figure,plot(odata(trial).Time,odata(trial).Markers{1}(1,:),'.')
hold on,plot(odata(trial).Time,odata(trial).Markers{1}(2,:),'.r')
hold on,plot(odata(trial).Time,odata(trial).Markers{1}(3,:),'.k')

t=1:length(result.moveRT)
figure, hold on
plot(t, result.trial_maxRT,'.k')
 plot(t(logical(result.trial_crossed(1:length(result.moveRT)))),result.moveRT(logical(result.trial_crossed(1:length(result.moveRT)))),'.r')
 plot(t(~logical(result.trial_crossed(1:length(result.moveRT)))),result.moveRT(~logical(result.trial_crossed(1:length(result.moveRT)))),'.b')
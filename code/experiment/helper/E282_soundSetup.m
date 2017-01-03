%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SOUND AND TACTILE STIMULATION SETTINGS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

exp.sound.fs                = 48000;                                            % sound sampling rate

% exp.sound.tactile_dur       = 1;        % this is set now in default settings       % tactile stimulation sinosouidal sound duration
exp.sound.tact_freq         = 200;
wave.tact                   = sin(2.*pi.*exp.sound.tact_freq.*...               % the tactile stimulus
                         [0:1/exp.sound.fs:exp.sound.tactile_dur-1/exp.sound.fs]);      

exp.sound.stBeep_dur        = .05;
exp.sound.stBeep_freq       = 2000;
wave.stBeep                 = sin(2.*pi.*exp.sound.stBeep_freq.*...             % the start beep
                         [0:1/exp.sound.fs:exp.sound.stBeep_dur-1/exp.sound.fs]);      
                        
exp.sound.lateBeep_dur      = .2;
exp.sound.lateBeep_freq     = 4000;
wave.lateBeep               = sin(2.*pi.*exp.sound.lateBeep_freq.*...             % the start beep
                         [0:1/exp.sound.fs:exp.sound.lateBeep_dur-1/exp.sound.fs]);      
exp.sound.earlyBeep_dur      = .2;
exp.sound.earlyBeep_freq     = 500;
wave.earlyBeep               = sin(2.*pi.*exp.sound.earlyBeep_freq.*...             % the start beep
                         [0:1/exp.sound.fs:exp.sound.earlyBeep_dur-1/exp.sound.fs]);      

                     
exp.sound.reachBeep_dur     = .05;
exp.sound.reachBeep_freq    = 2000;
wave.reachBeep              = sin(2.*pi.*exp.sound.reachBeep_freq.*...             % the start beep
                         [0:1/exp.sound.fs:exp.sound.reachBeep_dur-1/exp.sound.fs]);      
if strcmp(sTtyp,'sfix')
    exp.sound.seq_dur           = 3;                                        % her one channel gives the sequence of beeps plus noise and the other one the tactile stimulus
    exp.sound.stBeep_freq       = 2000;
    exp.sound.seqBeeps_time     = .5;
    wave.seq                    = [zeros(1,exp.sound.seq_dur*exp.sound.fs);...
                                    rand(1,exp.sound.seq_dur*exp.sound.fs)/2-.25];
    for e = 1:4
        indxBeep                = e*exp.sound.seqBeeps_time*exp.sound.fs:...
                                    e*exp.sound.seqBeeps_time*exp.sound.fs+...
                                    exp.sound.stBeep_dur*exp.sound.fs-1;
        wave.seq(2,indxBeep)       = 2*sin(2.*pi.*exp.sound.stBeep_freq.*...             % the start beep
                             [0:1/exp.sound.fs:exp.sound.stBeep_dur-1/exp.sound.fs]); 
    end
elseif strcmp(sTtyp,'sfive')
    exp.sound.seq_dur           = 3;                                        % her one channel gives the sequence of beeps plus noise and the other one the tactile stimulus
    exp.sound.stBeep_freq       = 2000;
    exp.sound.seqBeeps_time     = .5;
    wave.seq                    = [zeros(1,exp.sound.seq_dur*exp.sound.fs);...
                                    rand(1,exp.sound.seq_dur*exp.sound.fs)/2-.25];
    for e = 1:5
        indxBeep                = e*exp.sound.seqBeeps_time*exp.sound.fs:...
                                    e*exp.sound.seqBeeps_time*exp.sound.fs+...
                                    exp.sound.stBeep_dur*exp.sound.fs-1;
        wave.seq(2,indxBeep)       = 2*sin(2.*pi.*exp.sound.stBeep_freq.*...             % the start beep
                             [0:1/exp.sound.fs:exp.sound.stBeep_dur-1/exp.sound.fs]); 
    end
end

%wavedata1                   = rand(1,freq*dur)*2-1;                         % the noise

                 
exp.sound.nrchannels        = 2;                                            % ditto

InitializePsychSound;                                                       % Perform basic initialization of the sound driver:

try                                                                         % Try with the 'freq'uency we wanted:
    pahandle = PsychPortAudio('Open', [], [], 0, exp.sound.fs, exp.sound.nrchannels);
catch                                                                       % Failed. Retry with default frequency as suggested by device:
    fprintf('\nCould not open device at wanted playback frequency of %i Hz. Will retry with device default frequency.\n', exp.sound.fs);
    fprintf('Sound may sound a bit out of tune, ...\n\n');
    psychlasterror('reset');
    pahandle = PsychPortAudio('Open', [], [], 0, [], exp.sound.nrchannels);
end

% sound example figure for sequence tone
%  result.trial_maxRT = .250
%   next_trial =1
%   wavetact        = sin(2.*pi.*exp.sound.tact_freq.*...               % the tactile stimulus
%                          [0:1/exp.sound.fs:result.trial_maxRT(next_trial)-1/exp.sound.fs]);
% wavetact        = wavetact.*fliplr([0:1/exp.sound.fs/result.trial_maxRT(next_trial):1-1/exp.sound.fs/result.trial_maxRT(next_trial)]);
% wave.seq(1,4*exp.sound.seqBeeps_time*exp.sound.fs:4*exp.sound.seqBeeps_time*exp.sound.fs+length(wavetact)-1) = wavetact;
% t = 1/exp.sound.fs:1/exp.sound.fs:1/exp.sound.fs*size(wave.seq,2);
%  figure,plot(t,wave.seq(2,:))
%   hold on,plot(t,wave.seq(1,:),'r')
% this go in the trial structure 'Stop' is not necessary
% tic
% wavedata                    = [wave_stBeep ; wave_stBeep];     
% 
% PsychPortAudio('FillBuffer', pahandle, wavedata);toc                           % Fill the audio playback buffer with the audio data 'wavedata':
% % PsychPortAudio('Volume', pahandle,win.wn_vol);                              % Sets the volume (between 0 and 1)
% % s = PsychPortAudio('GetStatus', pahandle);                                  % Status of the port, necessary later to defice wheter to start or stop audio
% t1      = PsychPortAudio('Start', pahandle, 1, 0, 0);
% toc
% PsychPortAudio('Stop', pahandle);   
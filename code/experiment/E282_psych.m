DIO    = digitalio('nidaq','Dev1');                                        % control the DI/O nidaq card PCI 6509  
lines  = addline(DIO,0:7,0,'Out');                                         % Output thorugh port 0 
lines  = addline(DIO,6:7,9,'In');                                          %Input thorugh port 9, for button press 
putvalue(DIO.line(1:8),0)                                                  % flush it   

exp.sound.fs                = 48000;                                            % sound sampling rate
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

%%
% first step get threshold
nTrials = 100;
tGuess      = -1.2;
tGuessSd    = 1;
pThreshold  = 0.82;
beta        = 3.5;
delta       = 0.02;
gamma       = 0.5;
q           = QuestCreate(tGuess,tGuessSd,pThreshold,beta,delta,gamma);

tIntensity  = QuestQuantile(q);

exp.sound.tactile_dur = .025;  
exp.sound.tact_freq   = 200;
wave.tact             = sin(2.*pi.*exp.sound.tact_freq.*...               % the tactile stimulus
                         [0:1/exp.sound.fs:exp.sound.tactile_dur-1/exp.sound.fs]);      
wave.tact(2,:)        = 0; % sound cha   nnel
randSOA               = .5+rand(nTrials,1);   
response = 0;          
%%
tic
for t= 1:nTrials
    if t ==1
        lastStim      = GetSecs;                     
        side          = 1;
    end
    PsychPortAudio('FillBuffer', pahandle, wave.tact.*10.^tIntensity);             % this takes less than 1 ms
    display(sprintf('Stimulus %d Intensity %1.3f',t,10.^tIntensity))
    
    PsychPortAudio('Start', pahandle, 0,0,0);    % repeats infitnely, starts as soon as posible, and continues with code inmediatly (we are contrling the stimulation with the parallel port so it does not matter)
    toc
    WaitSecs(randSOA(t));
    toc
    putvalue(DIO.line(1:8),dec2binvec(side,8));     % 
    toc
    lastStim      = GetSecs;    
    toc
    WaitSecs(exp.sound.tactile_dur);
    toc
    putvalue(DIO.line(1:8),dec2binvec(0,8));     % stimulation channel is on during the complete trial
    toc
    PsychPortAudio('Stop', pahandle);
    toc
    sttime = GetSecs;
    while GetSecs-lastStim<1
        outVal = getvalue(DIO.Line(9:10));
        if outVal(1) == 0
            response = 1;
            display(sprintf('Button 1 pressed %4.3f seconds',GetSecs-lastStim))
            break
        end
    end
    if response == 1
        q=QuestUpdate(q,tIntensity,1); 
        response = 0;
    else
         q=QuestUpdate(q,tIntensity,0); 
    end
    tIntensity  = QuestQuantile(q);
end

%%
display(sprintf('\nIntensity threhsold: %1.3f\nIntensity sd: %1.3f',10.^QuestMode(q),10.^QuestSd(q)))
%% 
% E282 experimental code
% Generated from old TOJ experiment

%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Setup: matlab stuff, experimental setting, calibration of the coordinate
% system and initialize of Optotrack
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% some cleaning of matlab stuff
clc
close all
clear functions
% KbName('UnifyKeyNames');
% escapeKey = KbName('ESCAPE');
RandStream.setGlobalStream(RandStream('mt19937ar','seed',sum(100*clock)));

% experiment settings
exp.ntrials                 = 50; % number of trials
% plot_fig        = 0;
% usePorts        = 1;
exp.time_trial              = 5;                % max. length collection time

exp.pos.origen                  = [162 -6];     % start and target positions, and tolerance radius
exp.pos.left                    = [107 167];
exp.pos.right                   = [227 161]; 
exp.pos.radius                  = 10;            
% Optotrak Settings: TODO: check all this parameters
exp.coll.NumMarkers             = 5;                                        %Number of markers in the collection.
exp.coll.FrameFrequency         = 400;                                      %Frequency to collect data frames at. Specify the rate that data for all markers can be sampled. ~MarkerFrequency/(Numbre of Markers + 1.3)
exp.coll.MarkerFrequency        = 3000;                                     %Marker frequency for marker maximum on-time. 
exp.coll.Threshold              = 30;                                       %Dynamic or Static Threshold value to use.
exp.coll.MinimumGain            = 160;                                      %Minimum gain code amplification to use.
exp.coll.StreamData             = 0;                                        %Stream mode for the data buffers.
exp.coll.DutyCycle              = 0.5;                                      %Marker Duty Cycle to use. Is the fraction of the marker period that the marker is turned on. Bounds [.1-.85], default = 0.5
exp.coll.Voltage                = 7;                                        %Voltage to use when turning on markers. Is the voltage applied to the markers. Bounds [7-12], default = 7
exp.coll.CollectionTime         = exp.time_trial;                               %Number of seconds of data to collect.
exp.coll.PreTriggerTime         = 0;                                        %Number of seconds to pre-trigger data by.
exp.coll.Flags                  = {'OPTOTRAK_BUFFER_RAW_FLAG';...           % TODO: check what this flags are
                                'OPTOTRAK_GET_NEXT_FRAME_FLAG'};
% Parameters for calibration with table markers:
exp.CalibColl.NumMarkers                = exp.coll.NumMarkers;              %Number of markers in the calibration collection.         
exp.CalibColl.FrameFrequency            = 100;                                           
exp.CalibColl.TableMarkersStartMarker   = 3;                                % Markers for calibration should be at the marker strober StartMarker and the next two, first is the origin, second x axis, third define plane
exp.CalibColl.calibcoorNcollect         = 100;                              % TODO: check what are this parameters
exp.CalibColl.calibcoorMaxStd           = 0.1;
exp.CalibColl.CAMfile                   = 'E282calibcoor';

% Calibrate the coordinate system to one defined with three markers
% displaced in the experiment table
exp.CalibColl = E282_calibcoor(exp.CalibColl);

%%
% Initialize optotrack
tic,optotrak('TransputerLoadSystem','system'),toc;pause(12);                         %Load the system of transputers. This reallz takes long tme and if we do not pause then the camera parameters are not loaded
optotrak('TransputerInitializeSystem',{'OPTO_LOG_ERRORS_FLAG'});pause(2);   %Initialize the transputer system.
optotrak('OptotrakLoadCameraParameters',exp.CalibColl.CAMfile);pause(2);          % this loads the custom coordinate sstem obtained with calibcoor
optotrak('OptotrakSetupCollection',exp.coll);                               %Set up a collection for the OPTOTRAK.
optotrak('OptotrakPrintStatus')

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check setup
% We check that the movement of the finger marker match with the model of
% the table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

E282_check_setup

%%
exp.subjname = input('Name: ','s');

mkdir('C:\Users\bpn\Desktop\E282\data\',exp.subjname)

rp = randperm((ntrials));
rps = randperm((ntrials));

disp(['number of trials is: ',num2str(ntrials)])

% time of tactile stimulus
tstim = 0.05:0.001:0.800;

tstim = tstim(randperm(length(tstim)));
tstim = tstim(1:ntrials);

t_end = tstim;

% toj_delay = [0.05*ones(round(ntrials/2),1);0.11*ones(round(ntrials/2),1)];
% toj_delay = toj_delay(randperm(length(toj_delay)));

toj_delay = 0.11*ones(round(ntrials),1);

stimorder = [ones(round(ntrials/2),1);2*ones(round(ntrials/2),1)];
stimorder = stimorder(randperm(length(stimorder)));

stimorder2 = 3-stimorder;

%% create sound
InitializePsychSound(1);

if ~IsLinux
    PsychPortAudio('Verbosity', 10);
end

reqlatencyclass = 2; % class 2 empirically the best, 3 & 4 == 2
nrchannels = 2;
buffersize = 0; % Pointless to set this. Auto-selected to be optimal.
freq =  8192;%44100;%8192;

%pahandle = PsychPortAudio('Open', [], [], reqlatencyclass, freq, nrchannels);
%pahandle = PsychPortAudio('Open', deviceid, [], reqlatencyclass, freqsample, 2, buffersize);
pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);

% geluidsfrequentie
f    = 2500;
duur = 0.005;

% harde stim
stimH(1,:) = 1*MakeBeep(f,duur,freq);
stimH(2,:) = stimH(1,:);

f    = 1000;

stimW(1,:) = 1*MakeBeep(f,duur,freq);
stimW(2,:) = stimW(1,:);


% Fill buffer with data:
PsychPortAudio('FillBuffer', pahandle, stimH);
PsychPortAudio('Start', pahandle, 1, 0, 1);
WaitSecs(1);
PsychPortAudio('Stop', pahandle,1);
WaitSecs(0.5);

%% COM poorten
% check whether the program has run before, and if so, close the serial port (otherwise we cannot open it again, and need to restart matlab)
if exist('ser', 'var')
    if strcmp(class(ser), 'serial')
        fprintf('\nclosing serial port from last instance...');
        fclose(ser);
    end
end
% if exist('s2', 'var')
%     if strcmp(class(s2), 'serial')
%         fprintf('\nclosing serial port from last instance...');
%         fclose(s2);
%     end
% end

daqOutP0('close');

if usePorts
    fprintf('\n\nPATIENCE:\nopening parallel/nidaq/DT ports...');
    
    % call c routines from Adjmal/Ivar (Nijmegen)
    % very non-elegant, but it works: 100.000 calls for port reading per
    % second
end

%##########################################################################
% define serial port for tactile box
%##########################################################################
if usePorts
    fprintf('\nopening serial port...');
    
    ser = th_E184_create_serialport;
    try
        if strcmpi(ser.Status, 'closed')
            fopen(ser);
        end
    catch
        error('MATLAB:serial:fwrite:openserialfailed', lasterr);
        fclose(ser);
    end
    fprintf('done');
    
    fprintf('\nwriting to serial port...');
    ok = th_E184_define_stim_states(ser);
    if ok ~= 1
        fprintf('\n failed writing stimulus codes to serial port!\n');
    end
    fprintf('done');
    
else
    fprintf('testing, skipping serial port');
end

% s2 = serial('COM8','BaudRate', 115200); % Odau meant for timing of tactile stim
% % open COM
% fopen(s2);

if usePorts
    daqOutP0('open'); % for tactile stim
end

%WaitSecs(1)
pause(1)

%% save the data in the new folder that's made above
cd(['C:\Users\bpn\Documents\E184\Femke\',num2str(name)])

%% turn on markers
%Activate the markers.
optotrak('OptotrakActivateMarkers')

%% start exp
t_press = NaN(ntrials,1);
start_trial = cell(1,ntrials);
flagstimdone = 0;
for nt = 1:ntrials
    %  beep;
    cntled   = 0;
    cntsound = 0;
    disp(nt)
    PsychPortAudio('FillBuffer', pahandle, stimH);
    
   % fwrite(s2,0)       % op odau
    
    %Initialize a file for spooling of the OPTOTRAK data.
%     optotrak('DataBufferInitializeFile',{'ODAU1'},['O#00',num2str(nt),'.DAT']);
    optotrak('DataBufferInitializeFile',{'OPTOTRAK'},['R#00',num2str(nt),'.DAT']);
    
    %Start the OPTOTRAK spooling data to us.
    optotrak('DataBufferStart');
    fprintf('Collecting data file...\n');
    PsychPortAudio('Start', pahandle, 1, 0, 1);
    start_trial{nt} = optotrak('DataGetLatest3D',coll.NumMarkers);
    
    
    data_online = cell(1,coll.FrameFrequency*coll.CollectionTime);
    marker      = nan(coll.FrameFrequency*coll.CollectionTime,3);
    framenr     = nan(1,coll.FrameFrequency*coll.CollectionTime);
    cntd        = 0;
    time        = clock;
    while etime(clock,time)<time_trial 
        %  cntd              = cntd +1;

%         data=optotrak('DataGetLatest3D',coll.NumMarkers);
%         %Print out the data.
%         fprintf('Frame Number: %8u\n',data.FrameNumber);
%         fprintf('Elements    : %8u\n',data.NumMarkers);
%         fprintf('Flags       : 0x%04x\n',data.Flags);
%         for MarkerCnt = 1:coll.NumMarkers
%             fprintf('Marker %u X %f Y %f Z %f\n', MarkerCnt,...
%                 data.Markers{MarkerCnt}(1),...
%                 data.Markers{MarkerCnt}(2),...
%                 data.Markers{MarkerCnt}(3))
%         end
        

%         
        
        if etime(clock,time)>tstim(nt) && etime(clock,time)<tstim(nt)+0.005
            %fwrite(s2,30)
            if usePorts
                daqOutP0('write', stimorder(nt));
                WaitSecs(0.01);
                daqOutP0('write', 6);
            end
        elseif etime(clock,time)>tstim(nt)+toj_delay(nt) && etime(clock,time)<tstim(nt)+toj_delay(nt) + 0.005
            %fwrite(s2,20)
            if usePorts
                daqOutP0('write', stimorder2(nt));
                WaitSecs(0.01);
                daqOutP0('write', 6);
            end
            flagstimdone = 1;
        elseif flagstimdone
            %fwrite(s2,0)
            PsychPortAudio('Stop', pahandle,1);
            PsychPortAudio('FillBuffer', pahandle, stimW);
            flagstimdone = 0;
        %else
        %     if usePorts
        %        daqOutP0('write', 6);
        %    end
        end
        
        if etime(clock,time)>2.5 && etime(clock,time)<2.5+0.01
            PsychPortAudio('Start', pahandle, 1, 0, 1);
        end
    end
   % PsychPortAudio('FillBuffer', pahandle, stimW);
   % PsychPortAudio('Start', pahandle, 1, 0, 1);
    
    PsychPortAudio('Stop', pahandle,1);
    
    % end of that trial
    optotrak('DataBufferStop');
    
    %Loop around spooling data
    SpoolComplete=0;
    tic;
    while ~SpoolComplete
        %Write data if there is any to write.
        [RealtimeDataReady,SpoolComplete,SpoolStatus,FramesBuffered] = optotrak('DataBufferWriteData');
        %disp(['DataBufferWriteData: ' num2str(RealtimeDataReady) ' ' num2str(SpoolComplete) ' ' num2str(SpoolStatus) ' ' num2str(FramesBuffered)]);
    end
    optotrak('FileConvert',['R#00',num2str(nt),'.DAT'],['C#00',num2str(nt),'.DAT'],{'OPTOTRAK_RAW'});
        
    fprintf('Spooling took: %d seconds\n', toc);
   % fprintf('Spool Status: 0x%04x\n',SpoolStatus);
    PsychPortAudio('Stop', pahandle,1);
   
%     for MarkerCnt = 1:coll.NumMarkers
%         figure(1)
%         subplot(3,1,1)
%         plot(data.Markers{MarkerCnt}(1))
%         subplot(3,1,2)
%         plot(data.Markers{MarkerCnt}(2))
%         subplot(3,1,3)
%         plot(data.Markers{MarkerCnt}(3))
%     end
      [a,b,keyCode] = KbCheck;
        if keyCode(escapeKey)
            break;
        else
            WaitSecs(.1);
        end;
    
end

%% close


%fclose(s2);
daqOutP0('close');
PsychPortAudio('Close');
%
save(name)
%De-activate the markers.
optotrak('OptotrakDeActivateMarkers')
%Shutdown the transputer message passing system.
optotrak('TransputerShutdownSystem')

%Exit the program.
fprintf('\nProgram execution complete.\n');

disp('end of experiment')


%%

    %Name:             SAMPLE2.M

%Description:

%    OPTOTRAK Sample Program #2.

%    1.  Load the system of transputers with the appropriate
%        transputer programs.
%    2.  Initiate communications with the transputer system.
%    3.  Set the optional processing flags to do the 3D conversions
%        on the host computer.
%    4.  Load the appropriate camera parameters.
%    5.  Set up an OPTOTRAK collection.
%    6.  Activate the IRED markers.
%    7.  Request/receive/display 10 frames of real-time 3D data.
%    8.  De-activate the markers.
%    9.  Disconnect the PC application program from the transputer
%        system.

%cd('C:\Dokumente und Einstellungen\Versuchsleiter BPN\Eigene Dateien\MATLAB')

%Settings:
% coll.NumMarkers      =4;   %Number of markers in the collection.         
% coll.FrameFrequency  =150; %Frequency to collect data frames at.          
% coll.MarkerFrequency =800;%Marker frequency for marker maximum on-time. 
% coll.Threshold       =30;  %Dynamic or Static Threshold value to use.    
% coll.MinimumGain     =160; %Minimum gain code amplification to use.      
% coll.StreamData      =1;   %Stream mode for the data buffers.            
% coll.DutyCycle       =0.2;%Marker Duty Cycle to use.                    
% coll.Voltage         =7;   %Voltage to use when turning on markers.      
% coll.CollectionTime  =10;   %Number of seconds of data to collect.        
% coll.PreTriggerTime  =0;   %Number of seconds to pre-trigger data by.    
% coll.Flags={'OPTOTRAK_BUFFER_RAW_FLAG';'OPTOTRAK_GET_NEXT_FRAME_FLAG'};

%TODO TOBIAS: 
% coll.ModelType = 1; 
epar     = expSettings;

% %Load the system of transputers.
% optotrak('TransputerLoadSystem','system');
% 
% %Wait one second to let the system finish loading.
% pause(1);
% 
% %Initialize the transputer system.
% optotrak('TransputerInitializeSystem',{'OPTO_LOG_ERRORS_FLAG'});
% 
% %Set optional processing flags (this overides the settings in OPTOTRAK.INI).
% optotrak('OptotrakSetProcessingFlags',...
%          {'OPTO_LIB_POLL_REAL_DATA';
%           'OPTO_CONVERT_ON_HOST';
%           'OPTO_RIGID_ON_HOST'});

% %Load the standard camera parameters.
% optotrak('OptotrakLoadCameraParameters','E104_vp1');
% 
% %Set up a collection for the OPTOTRAK.
% optotrak('OptotrakSetupCollection', coll);
% 
% %Wait one second to let the camera adjust.
% coll_number = 0;    %used later to name files for collections
% pause(1);

%TODO TOBIAS: 
lfd=42;
exp=99;

%%Start Optotrak:
fprintf('Starting Optotrak...\n')
% epar.NumRigids=expStartOptotrak();
expStartOptotrak()
optotrak('OptotrakActivateMarkers')
pause(2);

%fprintf('activated markers\n');
if lfd < 10
    lfd_txt = ['0' num2str(lfd)];
else
    lfd_txt = ['L' num2str(lfd)];
end
exp_txt = ['E' num2str(exp)];

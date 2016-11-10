function epar=expSettings

%General experimental stuff:
epar.ExpName                 ='E282calibcoor';
%epar.Proceeding              = false;

%Collection for experiment:
epar.ExpColl.NumMarkers             =  4; %Number of markers in the collection.         
epar.ExpColl.FrameFrequency         =100; %Frequency to collect data frames at.          
epar.ExpColl.CollectionTime         =  3; %Number of seconds of data to collect.        
epar.ExpColl.Flags={'OPTOTRAK_BUFFER_RAW_FLAG'};


%Collection for use with digitizer probe:
% epar.DigitizeColl.NumMarkers     = 4;   %Number of markers in the collection.         
% epar.DigitizeColl.FrameFrequency =100; %Frequency to collect data frames at.          
% 
% %Marker positions:
 epar.TableMarkersStartMarker =  7; % this and the next two, first is the origin, second x axis, third define plane

%Rigid bodies:
% epar.Finger.RigidBodyIndex  = 1;%only change together with RigidBodyAddFromFile!!!
% epar.Finger.StartMarker     = 1; %First marker in the rigid body
% epar.Finger.Flags           = {'OPTOTRAK_RETURN_MATRIX_FLAG'};
% 
% epar.Thumb.RigidBodyIndex   = 2;%only change together with RigidBodyAddFromFile!!!
% epar.Thumb.StartMarker      = 4; %First marker in the rigid body
% epar.Thumb.Flags            = {'OPTOTRAK_RETURN_MATRIX_FLAG'};

% epar.Digitize.RigidBodyIndex = 3;%only change together with RigidBodyAddFromFile!!!
% epar.Digitize.StartMarker    = 1; %First marker in the rigid body
% epar.Digitize.RigFile        = '4_marker_tool_2010_03_12';%RIG file containing rigid body coordinates
% epar.Digitize.Flags          = {'OPTOTRAK_RETURN_MATRIX_FLAG'};

%   %Disc markers:
%   epar.LargeContextMarker      = 10;%todo
%   epar.SmallContextMarker      = 11;%todo
%   epar.ManEstMarker            = 12;%todo

%Calibration routines:
epar.calibcoorNcollect            = 100;
epar.calibcoorMaxStd              = 0.1;

epar.testpositionsNcollect        = 100;
epar.testpositionsMaxStd          = 0.1;
epar.testpositionsMaxErrorAllowed = 0.2;

epar.calibpositionsNcollect       = 100;
epar.calibpositionsMaxStd         = 0.1;

epar.calibpersonNcollect          =  50;
epar.calibpersonMaxStd            = 0.3;

%General filenames:
epar.CAMFile                 = 'E282calibcoor';
epar.GeneralPosFile          = './E282positions.mat';

% %Screen calibration:
% epar.screencalib.mm          = 228; %mm
% epar.screencalib.px          = 800; %pixel

%All tasks:
epar.PresentationTime        =   1; %sec, presentation of stimuli
epar.SelectionTime           =   3; %sec, selection of stimuli

% %StartBeep:
% epar.StartBeepFreq     =1000;%Hz
% epar.StartBeepDuration = 0.1; %sec
% epar.StartBeepLoudness = 0.4;

% %Grasp task:
% epar.Trials                  = [1:180];
% epar.TrialsSubject15         = [2:180];%HACK: one trial is missing in subject 015
% epar.DiscMarkerVisTestNo     =  10; %Repetitions DiscMarker must be visible
% epar.MaxDiscMarkerStd        = 0.1; %[mm] max std of DiscMarker tolerated
% epar.TooEarlyFrames          =   2; %[frames]
% epar.StartPosTolerance       =  20; %[mm], only used in experimental run
% epar.DiscPosTolerance        =  50; %[mm], only used in experimental run
% epar.DiscPos12cm             = 120; %[mm], only used in experimental run
% epar.DiscPos24cm             = 240; %[mm], only used in experimental run
% epar.DiscMarkerTolerance     =  30; %[mm], only used in experimental run
% 
% %Adjustment task: 
% epar.adjustment.delay = 0.01; %Delay of adjustments
% 
% %Mueller Lyer sizes: 
% xcal=mm2px(epar,0);
% ycal=mm2px(epar,0);
% epar.COMMONset.color=0;        %Color
% epar.COMMONset.cent=[1280/2+xcal,1024/2+ycal]; %Center
% epar.COMMONset.penw=mm2px(epar, 8); %Penwidth
% epar.COMMONset.penh=mm2px(epar, 1); %Penheight todo???
% epar.COMMONset.xoff=NaN;       %x offset of fins
% epar.COMMONset.yoff=NaN;       %y offset of fins
% epar.COMMONset.finl=NaN;       %fin-length
% epar.COMMONset.alph=NaN;       %angle of fins   
% 
% epar.BARset=epar.COMMONset;
% epar.BARxsign=1;
% epar.BARset.xoff=mm2px(epar,50); %+/- x-Offset of adjustment bar
% epar.BARset.yoff=mm2px(epar,25); %+/- y-Offset of adjustment bar
% epar.BARset.barlmin  =mm2px(epar,31); %Minimum bar length of adjustment bar  %31.12.07: ATTENTION BUG: barlmin and are barlrange are interchanged!!!
% epar.BARset.barlrange=mm2px(epar,20); %Range of bar length of adjustment bar %31.12.07: ATTENTION BUG: barlmin and are barlrange are interchanged!!!
% epar.BARset.drawbar= true;  %Bar is drawn
% epar.BARset.drawfins=false; %Fins are notdrawn
% 
% %todo: remove????:
% %VFnormalization:
% epar.StartVFVelCrit          =0.025;%[mm/msec=m/sec] Start of movement
% epar.ZTolerance              = 3;   %[mm] New way to determine when touched object
% %epar.DiscDistCrit            =   40;%[mm]            Touched object (distance to target disc)
% %epar.DiscVelCrit             =0.010;%[mm/msec=m/sec] Touched object (disc movement)
% epar.HoldVelCrit             =0.010;%[mm/msec=m/sec] Holding object (aperture velocity)
% epar.HoldVelFlatFrames       =   15;%frames
% epar.RealHoldDistCrit        =  0.5;%Distance between disc and finger rest pos.
% epar.NormVFTimes             =[0:5:150];
% epar.SavetyMargin            =    1;%[mm]
% epar.MinRTVF                 = 100;
% epar.MaxRTVF                 =1200; %original was: 800;
% epar.MinMTVF                 = 250;
% epar.MaxMTVF                 =2700; %original was: 1500;
% 
% %ActiveWire for goggles and Kleinholdermann-LEDs:
% epar.GoggleID = 1;
% epar.DirectionMat = [1 1 1 1 1 1 1 1 1 1 1 1 1 1 1 1];
% epar.BothEyeOpen  = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0];
% epar.RightEyeOpen = [0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0];
% epar.LeftEyeOpen  = [0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0];
% epar.BothEyeClose = [0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0];
% %todo: epar.LED1         = [1 1 1 1 1 0 0 0 1 1 1 1 1 1 1 1];
% epar.LED2         = [0 1 1 1 1 0 0 0 1 1 1 1 1 1 1 1];
% epar.LED3         = [1 0 1 1 1 0 0 0 1 1 1 1 1 1 1 1];
% epar.LED4         = [1 1 0 1 1 0 0 0 1 1 1 1 1 1 1 1];
% epar.LED5         = [1 1 1 0 1 0 0 0 1 1 1 1 1 1 1 1];
% epar.LED6         = [1 1 1 1 0 0 0 0 1 1 1 1 1 1 1 1];
% epar.LED7         = [1 1 1 1 1 0 0 0 0 1 1 1 1 1 1 1];
% epar.LED8         = [1 1 1 1 1 0 0 0 1 0 1 1 1 1 1 1];
% epar.LED9         = [1 1 1 1 1 0 0 0 1 1 0 1 1 1 1 1];
% epar.LEDOff       = [1 1 1 1 1 0 0 0 1 1 1 1 1 1 1 1];

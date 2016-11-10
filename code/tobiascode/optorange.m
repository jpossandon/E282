function optorange(NumMarkers,CAMFile)
%EXAMPLES:
%  optorange 
%  optorange 5 
%  optorange 5 standard 
%
%Note: keep this as independent from the experiment as possible...

%Handle input:
%... NumMarkers:
if nargin==0
  NumMarkers=1;
elseif nargin>=1
  if ischar(NumMarkers) NumMarkers=str2double(NumMarkers); end
end
%... CAMFile:
if nargin<=1
  %Use CAMFile from experiment if not specified explicitly:
  epar=expSettings;
  CAMFile = epar.CAMFile;
  clear('epar');%Here we are strict, aren't we???
end

%Settings:
coll.NumMarkers      =NumMarkers; %Number of markers in the collection.         
coll.FrameFrequency  =100;        %Frequency to collect data frames at.          
clear('NumMarkers');

%Start optotrak:
optotrak('TransputerLoadSystem','system');
pause(1);
optotrak('TransputerInitializeSystem')
optotrak('OptotrakLoadCameraParameters',CAMFile)
optotrak('OptotrakSetupCollection',coll);
pause(1);

%Measure positions:
optotrak('OptotrakActivateMarkers');
while 1
  clc;
  %Handle keypresses:
  fprintf('   --- Quit optorange with q or escape --- \n')
  [keyIsDown,secs,keyCode] = KbCheck;
  if keyCode(KbName('q')) | keyCode(KbName('esc'))
    FlushEvents('keyDown'); %discard chars from event queue.
    fprintf('Quitting...')
    break;
  end
  %Get & display data:
  odata=optotrak('DataGetNext3D',coll.NumMarkers);
  for i = 1:coll.NumMarkers
    m=odata.Markers{i};
    fprintf('Marker %3i: X=%10.2f Y=%10.2f Z=%10.2f\n',i,m(1),m(2),m(3));
  end
  pause(0.2)
end
optotrak('OptotrakDeActivateMarkers')
optotrak('TransputerShutdownSystem')
disp(' program execution complete and Optotrak shut down.')

%NOTE: try/catch with Ctrl-C does no longer work: 
%try, while 1, disp('still running'), pause(1), end, catch, lasterr, end
%TRY/CATCH no longer catches Ctrl-C interruptions as of MATLAB 6.5
%(R13). This change in behavior was intentional. There are no known
%workarounds for reverting to the previous behavior.


function expStartOptotrak()

%Note: Optotrak must be started in the same way called by the experiment 
%      as well as by the conversion routine.

%%TODO TOBIAS:
SubFiles.FingerRigFile='data-finger';
SubFiles.ThumbRigFile ='data-thumb';

%Gateway to general settings of experiments:
epar=expSettings;
CAMFile          = epar.CAMFile;
coll             = epar.ExpColl;
% Thumb  = epar.Thumb;
% Finger = epar.Finger;
clear('epar');%Here we are strict, aren't we???

%Start Optotrak:
optotrak('TransputerLoadSystem','system');
pause(1);
optotrak('TransputerInitializeSystem',{'OPTO_LOG_ERRORS_FLAG';'OPTO_LOG_MESSAGES_FLAG'})
optotrak('OptotrakLoadCameraParameters',CAMFile);
%HACK: 
done=false;
while(~done)
  done=true;
  try
    optotrak('OptotrakSetupCollection',coll);
  catch
    disp('Trying again in a moment')
    done=false;
  end
  try
    optotrak('OptotrakActivateMarkers');
  catch
%%    disp('Trying again in a moment')
%%    done=false;
  end
  pause(1);
end

%Add the rigid bodies:
% Finger.RigFile = SubFiles.FingerRigFile;
% optotrak('RigidBodyAddFromFile',Finger);
% NumRigids = 1;
% pause(1);
% Thumb.RigFile = SubFiles.ThumbRigFile;
% optotrak('RigidBodyAddFromFile',Thumb);
% NumRigids = 2;
pause(1);

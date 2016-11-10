%For the paranoid we clear the workspace:
close all
clear functions

%%Settings: 
set_matlab_paths
epar = expSettings;

%%Start Optotrak:
fprintf('Starting Optotrak...\n')
epar.NumRigids=expStartOptotrak();

for trial = 1:2
  %%Set name of raw data file:
  optotrak('DataBufferInitializeFile',{'OPTOTRAK'},['data_trial',num2str(trial),'.raw']);
  pause(3)
  
  %Start the OPTOTRAK spooling data to us.
  optotrak('DataBufferStart')
  
  %Request a frame of realtime 3D data.
  optotrak('RequestLatestTransforms')

  %Loop around spooling data to file and displaying realtime 3d data.
  SpoolComplete=0;
  a=1
  while(~SpoolComplete)
    %Write data if there is any to write.
    [RealtimeDataReady,SpoolComplete,SpoolStatus,FramesBuffered]=optotrak('DataBufferWriteData');
    
    %Display realtime if there is any to display.
    if(RealtimeDataReady)
      %Receive the 3D data.
%       data=optotrak('DataReceiveLatestTransforms',epar.ExpColl.NumMarkers,epar.NumRigids);
       data(a)=optotrak('DataReceiveLatestTransforms',epar.ExpColl.NumMarkers,0);
      %Print out the data.
%       fprintf('Frame Number: %8u\n',data.FrameNumber);
%       fprintf('Elements    : %8u\n',data.NumMarkers);
%       fprintf('Flags       : 0x%04x\n',data.Flags);
%       finger=data.Rigids{epar.Finger.RigidBodyIndex}.Trans;
%       thumb =data.Rigids{epar.Thumb.RigidBodyIndex}.Trans;
%       fprintf('Finger: X %8.2f Y %8.2f Z %8.2f\n',...
%               finger(1),...
%               finger(2),...
%               finger(3))
%       fprintf('Thumb:  X %8.2f Y %8.2f Z %8.2f\n',...
%               thumb(1),...
%               thumb(2),...
%               thumb(3))
      a=a+1;
    end
    
    %Request a new frame of realtime 3D data.
    optotrak('RequestLatestTransforms')
  end
  fprintf('Spool Status: 0x%04x\n',SpoolStatus);
  
  while(~optotrak('DataIsReady'))
    fprintf('Data not ready yet\n');
  end

  %Convert to binary 3D data and save those: 
  optotrak('FileConvert',['data_trial',num2str(trial),'.raw'],['data_trial',num2str(trial),'.PC3D'],{'OPTOTRAK_RAW'});
  %Read binary 3D data to Matlab...:
  odata=optotrak('Read3DFileWithRigidsToMatlab',['data_trial',num2str(trial),'.PC3D'],epar.NumRigids);
  %...and save those as MAT file:
  save(['data_trial',num2str(trial),'.mat'],'odata','-mat');
  
  %...and plot the data:
  figure
  hold on
  %Plot single markers: 
  plot3(data.Markers{1}(1,:),data.Markers{1}(2,:),data.Markers{1}(3,:),'r*')
  plot3(data.Markers{2}(1,:),data.Markers{2}(2,:),data.Markers{2}(3,:),'g*')
  plot3(data.Markers{3}(1,:),data.Markers{3}(2,:),data.Markers{3}(3,:),'b*')
  plot3(data.Markers{4}(1,:),data.Markers{4}(2,:),data.Markers{4}(3,:),'m*')
  plot3(data.Markers{5}(1,:),data.Markers{5}(2,:),data.Markers{5}(3,:),'y*')
  plot3(data.Markers{6}(1,:),data.Markers{6}(2,:),data.Markers{6}(3,:),'c*')
  %... and the converted values for finger+thumb:
  finger=odata.Rigids{epar.Finger.RigidBodyIndex}.Trans;
  thumb =odata.Rigids{epar.Thumb.RigidBodyIndex}.Trans;
  plot3(finger(1,:),finger(2,:),finger(3,:),'k*')
  plot3(thumb(1,:),thumb(2,:),thumb(3,:),'k*')
end


%%HACK
try
  optotrak('OptotrakDeActivateMarkers')
end
try
  optotrak('TransputerShutdownSystem')
end


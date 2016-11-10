function calibcoor()
%Description:

%Settings:
OldCAMFile              ='standard';

%Gateway to general settings of experiments:
epar=expSettings;
NewCAMFile              =epar.CAMFile;
TableMarkersStartMarker =epar.TableMarkersStartMarker;
coll                    =epar.CalibColl;
Ncollect                =epar.calibcoorNcollect;
MaxStd                  =epar.calibcoorMaxStd;
clear('epar');%Here we are strict, aren't we???

disp(['Old camera parameter file: c:\ndigital\realtime\',OldCAMFile]);
disp(['We attempt to generate   : c:\ndigital\realtime\',NewCAMFile]);

%Start optotrak:
optostart(OldCAMFile,coll);
optotrak('OptotrakActivateMarkers');

%Measure positions:
[OriginMean,xDirMean,xyPlaneMean]=...
    optoMeasureTableMarkers(Ncollect,MaxStd,coll.NumMarkers,TableMarkersStartMarker);

%Transform the frame of reference: OldCAMFile -> NewCAMFile:
result=optotrakEasyChangeCameraFOR(OldCAMFile,NewCAMFile,OriginMean,xDirMean,xyPlaneMean);
disp(['RmsError: ',num2str(result.RmsError)]);

%... finish
optostop;

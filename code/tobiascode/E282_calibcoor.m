function new_CalibColl = E282_calibcoor(CalibColl)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% new_expset = E282_calibcoor(expset)
% Changes the coordinate system from the optotrack default (centered at the 
% optotrack) to one centered around three markers defined by the user
% The following parameteers are needed in the input expset structure
%   .CAMFile                 - string with the name of the experiment new 
%                              camera parameter file
%   .calibcoorNcollect       - 
%   .calibcoorMaxStd         -
%   .coll.NumMarkers         -
%   .TableMarkersStartMarker - at which # in the marker strober start the
%                               calibration markers. First is the origin,
%                               second the x axis, and the thirs one
%                               defines the plane
% JPO 24.06.16
% Hamburg, RtL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 % Markers for calibration should be at the marker strober StartMarker and the next two, first is the origin, second x axis, third define plane
%%
OldCAMFile              = 'standard';

disp(['Old camera parameter file: c:\ndigital\realtime\',OldCAMFile]);
disp(['We attempt to generate   : c:\ndigital\realtime\',CalibColl.CAMfile]);

optostart(OldCAMFile,CalibColl);                                     %Start optotrak:
optotrak('OptotrakActivateMarkers');

[OriginMean,xDirMean,xyPlaneMean] = optoMeasureTableMarkers(...             % Measure position of the three table markers that define the new coordinate system
                                    CalibColl.calibcoorNcollect,... 
                                    CalibColl.calibcoorMaxStd,...
                                    CalibColl.NumMarkers,...
                                    CalibColl.TableMarkersStartMarker);


CalibColl.calibresult                = optotrakEasyChangeCameraFOR(...          %Transform the frame of reference: OldCAMFile -> NewCAMFile:
                                    OldCAMFile,CalibColl.CAMfile,...
                                    OriginMean,xDirMean,xyPlaneMean);

disp(['RmsError: ',num2str(CalibColl.calibresult.RmsError)]);
optostop;
new_CalibColl                       = CalibColl;
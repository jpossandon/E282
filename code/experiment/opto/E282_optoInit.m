% E282_optoInit

% Calibrate the coordinate system to one defined with three markers
% displaced in the experiment table
exp.CalibColl = E282_calibcoor(exp.CalibColl);

% Initialize optotrack
tic,optotrak('TransputerLoadSystem','system'),toc;pause(12);                %Load the system of transputers. This reallz takes long tme and if we do not pause then the camera parameters are not loaded
optotrak('TransputerInitializeSystem',{'OPTO_LOG_ERRORS_FLAG'});pause(2);   %Initialize the transputer system.
optotrak('OptotrakLoadCameraParameters',exp.CalibColl.CAMfile);pause(2);    % this loads the custom coordinate sstem obtained with calibcoor
optotrak('OptotrakSetupCollection',exp.coll);                               %Set up a collection for the OPTOTRAK.
optotrak('OptotrakPrintStatus')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Check setup
% We check that the movement of the finger marker match with the model of
% the table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
aux_inpx = input('\nDo you want to check the table setup (y/n) : ','s');
if strcmp(aux_inpx,'y') 
    E282_check_setup(exp)
end
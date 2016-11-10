%Activate the markers.
%optotrak('OptotrakActivateMarkers')

%TODO TOBIAS
coll_number=99;

%Initialize a file for spooling of the OPTOTRAK data.
coll_number = coll_number + 1;

%lfd must be set from presentation
%pnr must be set from presentation
optotrak('DataBufferInitializeFile',{'OPTOTRAK'},['R#' num2str(coll_number) '.' lfd_txt '-' exp_txt]);

%Start the OPTOTRAK spooling data to us.
optotrak('DataBufferStart')




optotrak('DataBufferStop');
%t = GetSecs;
SpoolComplete = 0;
while(~SpoolComplete)
    [RealtimeDataReady,SpoolComplete,SpoolStatus,FramesBuffered]=optotrak('DataBufferWriteData');
end
optotrak('FileConvert',['R#' num2str(coll_number) '.' lfd_txt '-' exp_txt],['C#' num2str(coll_number) '.' lfd_txt '-' exp_txt],{'OPTOTRAK_RAW'});
%GetSecs - t

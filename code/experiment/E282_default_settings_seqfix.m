% default experiment settings structure
exp.nTrials                     = 475;                                      % total number of trials
exp.nBlocks                     = 19;                                        % total number of blocks
exp.trial_per_block             = repmat(exp.nTrials./exp.nBlocks,1,exp.nBlocks); % trials per block can be flexible adjusted so no all blocks have the same amount of trials (e.g. shorter test block)
exp.testBlocks                  = 1;                                        % first # blocks are test and will not be used for analysis
% exp.maxRT                       = [800,750,750,450,450,425,425,...
%                                    400,400,375,375,350,350,325,325]/1000;                  % max. RT in ms to move for each block, length of this vector must be equal to nBLocks. We have a lower limit in the first (test) block than in the second to show what happens, afterwards we have aneasy blcok with a high limit so we can get a baseline
exp.maxRT                       = repmat(75,exp.nBlocks,1);                  % max. RT in ms to move for each block, length of this vector must be equal to nBLocks. We have a lower limit in the first (test) block than in the second to show what happens, afterwards we have aneasy blcok with a high limit so we can get a baseline

exp.soa_fix                     = 0/1000;
exp.soa_rnd                     = 400/1000;
% plot_fig        = 0;
% usePorts        = 1;

exp.pos.origen                  = [330 0];     % start and target positions, and tolerance radius in mm from origin
exp.pos.left                    = [200 350]; %table
exp.pos.right                   = [460 350]; 
% exp.pos.left                    = [245 420]; %legs
% exp.pos.right                   = [415 420]; 
exp.pos.fix                     = [330 175];
exp.pos.radius                  = 40;            
% Optotrak Settings: TODO: check all this parameters
exp.coll.NumMarkers             = 5;                                        %Number of markers in the collection.
exp.coll.FrameFrequency         = 400;                                      %Frequency to collect data frames at. Specify the rate that data for all markers can be sampled. ~MarkerFrequency/(Numbre of Markers + 1.3)
exp.coll.MarkerFrequency        = 2600;                                     %Marker frequency for marker maximum on-time. 
exp.coll.Threshold              = 30;                                       %Dynamic or Static Threshold value to use.
exp.coll.MinimumGain            = 160;                                      %Minimum gain code amplification to use.
exp.coll.StreamData             = 0;                                        %Stream mode for the data buffers.
exp.coll.DutyCycle              = 0.5;                                      %Marker Duty Cycle to use. Is the fraction of the marker period that the marker is turned on. Bounds [.1-.85], default = 0.5
exp.coll.Voltage                = 7;                                        %Voltage to use when turning on markers. Is the voltage applied to the markers. Bounds [7-12], default = 7
exp.coll.CollectionTime         = 3.5;                                        %Number of seconds of data to collect. TODO: how does this work, it always save the full collection time?
exp.coll.PreTriggerTime         = 0;                                        %Number of seconds to pre-trigger data by.
exp.coll.Flags                  = {'OPTOTRAK_BUFFER_RAW_FLAG';...           % TODO: check what this flags are
                                'OPTOTRAK_GET_NEXT_FRAME_FLAG'};
% Parameters for calibration with table markers:
exp.CalibColl.NumMarkers                = exp.coll.NumMarkers;              %Number of markers in the calibration collection.         
exp.CalibColl.FrameFrequency            = 100;                                           
exp.CalibColl.TableMarkersStartMarker   = 3;                                % Markers for calibration should be at the marker strober StartMarker and the next two, first is the origin, second x axis, third define plane
exp.CalibColl.calibcoorNcollect         = 100;                              % TODO: check what are this parameters
exp.CalibColl.calibcoorMaxStd           = 0.1;
exp.CalibColl.CAMfile                   = 'E282calibcoor';

exp.sound.tactile_dur           = .05;  
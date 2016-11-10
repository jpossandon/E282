%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% E282_master
%
% This script controls the E282 experiment flexibly so it can be re-started
% at will, with different parameter, starting or continue with an optotrack
% session.
%
% JPO, Hamburg, 09.2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

splitStr                = regexp(fileparts(which('E282_master')),...        % this tells us the path to the experiment in any computer
                            ['code'],'split');          
Ppath                   = splitStr{1}; clear splitStr

[exp,result,next_trial] = E282_initialize_subject(Ppath);                   % initialize ore recovers subject folder, settings and result structure

%%
E282_optoInit                                                              % start and check optotrack

E282_soundSetup                                                             % setups the sound that drives the tactile stimulation and the feedback sounds

DIO    = digitalio('nidaq','Dev1');                                        % control the DI/O nidaq card PCI 6509  
lines  = addline(DIO,0:7,0,'Out');                                         % Output thorugh port 0 
putvalue(DIO.line(1:8),0)                                                  % flush it   

optotrak('OptotrakActivateMarkers')                                         % activate the markers.

% EXPERIMENTAL LOOP
while next_trial
    % something that tells the experimenter about blocks and trials
    if next_trial==sum(exp.trial_per_block)+1
        display(sprintf('\n\nEND OF THE EXPERIMENT\n\n'))
        break
    end
    if ismember(next_trial,[0 cumsum(exp.trial_per_block)]+1)
        if result.trial_crossed(next_trial)==0
            display(sprintf('\n\nBLOCK # %d START,\n CHECK THAT LEG POSITION IS UNCROSSED\n\n',result.trial_block(next_trial)))
        elseif result.trial_crossed(next_trial)==1
            display(sprintf('\n\nBLOCK # %d START,\n CHECK THAT LEG POSITION IS CROSSED\n\n',result.trial_block(next_trial)))
        end
        display(sprintf('\nMax. reaction time this block is %d ms\n',result.trial_maxRT(next_trial)*1000))
        aux_inp = input(sprintf('\nContinue (c) or stop (s) the experiment: '),'s');
    end 
    
    if strcmp(aux_inp,'c')    
        E282_trial_sequence
    elseif strcmp(aux_inp,'s')
        display(sprintf('\n\nEXPERIMENT INTERRUPTED\n\n'))
        break
    end
end    
if exist('odata')
    save(sprintf('%s%ss%s_odata.mat',exp.Spath,filesep,exp.sNstr),'odata')
end
%%
PsychPortAudio('Close');
optotrak('OptotrakDeActivateMarkers')                                       % de-activate the markers.
optotrak('TransputerShutdownSystem')                                        % shutdown the transputer message passing system.
disp(sprintf('\nend of experiment'))


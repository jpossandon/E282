function [exp,result,next_trial] = E282_initialize_subject(Ppath)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function E282_initialize_subject(Ppath)
%
% JPO, Hamburg, 16.09.16
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

sNstr           = input('\nSubject number: ','s');
Spath           = sprintf('%sdata%ss%s',Ppath,filesep,sNstr);              % path to subject data folder

% check wether subject folder exists and what does the experimenter want to do
if isdir(Spath)                        
    aux_inp1 = input(sprintf(...
        '\n\nSubject %s already exists, do you want to continue (c) or restart (r) a session: ',sNstr),'s');
    
    if strcmp(aux_inp1,'r')
        aux_inp2 = input(sprintf('\nAre you sure you want to erase subject data s%s (y/n) : ',sNstr),'s');
        if strcmp(aux_inp2,'y')                                             % erasing previous subject folder, we actually copy it first to .../data/removed
            display(sprintf('\n\nCopyng old data s%s to ...\\data\\removed folder...',sNstr))
            if ~isdir(sprintf('%sdata%sremoved%s',Ppath,filesep,filesep))
                mkdir(sprintf('%sdata%sremoved%s',Ppath,filesep,filesep));
            end
            [SUCCESS,MESSAGE,MESSAGEID] = copyfile(Spath,...
                sprintf('%sdata%sremoved%ss%s_%s%s',Ppath,filesep,filesep,sNstr,datestr(now,'ddmmyy'),filesep));
            if ~SUCCESS
                error(MESSAGEID,MESSAGE)
            end
            rmdir(Spath,'s')
            restart_flag = 1;
            cont_flag    = 0;
        elseif strcmp(aux_inp2,'n')
            error(sprintf('\n ... then you have to start again.\nFinishing program\n'))
        else 
            error(sprintf('\nYou did not anser ''y'' or ''n''\nFinishing program\n'))
        end
    elseif strcmp(aux_inp1,'c')
        restart_flag = 0;
        cont_flag    = 1;
    else 
        error(sprintf('\nYou did not anser ''r'' or ''c''\nFinishing program\n'))
    end
else 
   restart_flag = 1;
   cont_flag    = 0;
end
    
if restart_flag                                                             % create folder an subject specific setting structure
    display(sprintf('\n\nNew subject s%s,\n creating subject settings, result files and folder structure ...\n',sNstr))
    mkdir(sprintf('%sdata%ss%s',Ppath,filesep,sNstr))
    E282_default_settings
    exp.sNstr       = sNstr;
    exp.created     = datestr(now);
    save(sprintf('%s%ss%s_settings.mat',Spath,filesep,sNstr),'exp');
    create_result   = 1;
    for d=1:exp.nBlocks
        mkdir(sprintf('%sdata%ss%s%s%02d',Ppath,filesep,sNstr,filesep,d))
    end
end

if cont_flag
   display(sprintf('\nLoading setting for s%s and checking result file,',sNstr))
   load(sprintf('%s%ss%s_settings.mat',Spath,filesep,sNstr),'exp');
   display(sprintf(' previous setting file was created on the %s',exp.created))
   A = exist(sprintf('%s%ss%s_results.mat',Spath,filesep,sNstr),'file'); 
   if A == 0 
      display(sprintf('\nResult file for s%s does not exist,\n creating a new one',sNstr))
      create_result     = 1;
   elseif A==2
      display(sprintf('\nResult file for s%s exists,',sNstr))
      create_result     = 0;
      load(sprintf('%s%ss%s_results.mat',Spath,filesep,sNstr),'result')
      last_valid        =find(result.trial_done,1,'last');
      if ~isempty(last_valid)
          display(sprintf('\n%d/%d trials already done,',last_valid,exp.nTrials))
          cum_tBlocks   = [0,cumsum(exp.trial_per_block)];
          [LIA,LOCB]    = ismember(last_valid,cum_tBlocks);
          if LIA
            display(sprintf('\nPrevious session interrumpted at the end of block %d,\n we just continue with next block ...\n',LOCB))
          else
            curBlock    = sum(last_valid>=cum_tBlocks);
            display(sprintf('\nPrevious session interrumpted during Block # %d',curBlock))
            aux_inp3    = input(sprintf('\nDo you wish to restart (r) block %d or continue (c) with block %d: ',curBlock,curBlock+1),'s');
            if strcmp(aux_inp3,'r')
                trial_toremove = last_valid-(cum_tBlocks(curBlock));
                display(sprintf('\n\nRemoving %d trials from Block %d,\n we start from the beginning of the Block\n', trial_toremove, curBlock))
%                 if isfield(result,'old')
%                     result.old
%                 else
%                     result.old = result;
%                 end
                result.trial_done(last_valid-trial_toremove+1:last_valid) = 0;
                result.moveRT(last_valid-trial_toremove+1:last_valid) = NaN;
                result.reachRT(last_valid-trial_toremove+1:last_valid) = NaN;
                result.correct(last_valid-trial_toremove+1:last_valid) = NaN;
                next_trial = cum_tBlocks(curBlock)+1
            elseif strcmp(aux_inp3,'c')
                display(sprintf('\nWe continue the experiment from Block %d\n',curBlock+1))
                next_trial = cum_tBlocks(curBlock+1)+1;
            else 
                error(sprintf('\nYou did not anser ''r'' or ''c''\nFinishing program\n'))
            end
          end
      else
        display(sprintf('\nZero trials have been performed,\nwe start then from trial #1 ...\n'))
        next_trial = 1;
      end
      save(sprintf('%s%ss%s_results.mat',Spath,filesep,sNstr),'result')
   end
end

if create_result == 1                                                       % create new result file
    result.trial_done         = zeros(1,exp.nTrials);   
    result.trial_use          = zeros(1,exp.nTrials);
    result.trial_maxRT        = [];
    result.trial_block        = [];
    result.trial_crossed      = [];
%     result.cross_legs         = repmat(randsample([1 0],2),...              % 0 - uncrossed ; 1 - crossed 
%                                 1,exp.nBlocks);    
   result.cross_legs         = repmat([1 0],...              % 0 - uncrossed ; 1 - crossed 
                                1,exp.nBlocks);  
    result.side_legStim       = randsample([ones(1,exp.nTrials),...         % 0 - left ; 1 - right 
                                zeros(1,exp.nTrials)],exp.nTrials);
    cum_tBlocks               = [0,cumsum(exp.trial_per_block)];
    for b = 1:exp.nBlocks                                    
      result.trial_maxRT      = [result.trial_maxRT,exp.maxRT(b).*ones(1,exp.trial_per_block(b))];
      auxtrl                  = cum_tBlocks(b)+1:cum_tBlocks(b+1);
      result.trial_block      = [result.trial_block,b.*ones(1,exp.trial_per_block(b))];
      result.trial_crossed    = [result.trial_crossed,result.cross_legs(b).*ones(1,exp.trial_per_block(b))];
      if result.cross_legs(b) == 0
          result.trial_trigger(auxtrl)    = result.side_legStim(auxtrl)+1;
      elseif result.cross_legs(b) == 1
          result.trial_trigger(auxtrl)    = result.side_legStim(auxtrl)+5;
      end
    end
    
    result.soa                = exp.soa_fix+exp.soa_rnd.*rand(1,exp.nTrials);
    result.created            = datestr(now);
    save(sprintf('%s%ss%s_results.mat',Spath,filesep,sNstr),'result')
    next_trial = 1;
end
exp.Spath = Spath;
% E282_check_setup
%%
pl_len = -100:100:400;                                                      % coordinates and size of the grid
figure, hold on
mesh(pl_len,pl_len,-20*ones(length(pl_len)))                                % this is useful for 3D views

posfields           = fields(exp.pos);                                      % check all fields that are not radius      
posfields(strmatch('radius',posfields)) = [];
for pf = 1:length(posfields)                                                % draw circles at each position
    rectangle('Position',[exp.pos.(posfields{pf})-exp.pos.radius exp.pos.radius*2 exp.pos.radius*2],'Curvature',[1 1])
    text(exp.pos.(posfields{pf})(1)-exp.pos.radius,exp.pos.(posfields{pf})(2)-2*exp.pos.radius,posfields{pf})
end
axis([pl_len(1) pl_len(end) pl_len(1) pl_len(end) pl_len(1) pl_len(end)/2]) 
% view([-20 30])
data=optotrak('DataGetNext3D',exp.coll.NumMarkers);                         % get optotrack data
curdata = cell2mat(data.Markers')';                                         % transform so is a matrix with sensor rows and x,y,z columns
tms = exp.CalibColl.TableMarkersStartMarker;
plot3(curdata(tms,1),curdata(tms,2),curdata(3,3),'.r')                          % plot the markers that set the coordinate system
plot3(curdata(tms+1,1),curdata(tms+1,2),curdata(4,3),'.b')
plot3(curdata(tms+2,1),curdata(tms+2,2),curdata(5,3),'.g')

cont_flag       = 1;                                                        % flag to advance across positions
tail_len        = 20;                                                       % number of position samples to show at a given time
cols            = linspace(1,0,tail_len);                                   % to change the color of the tail
minnum_samples  = 20;
ai =1;
while cont_flag                                                             % we continue checking the data until all the position have been verified
    
    t = text(pl_len(2),pl_len(end-1),sprintf('Please put the marker at %s',posfields{cont_flag}),'FontSize',14);  %Instruction for the experimenter
        
    data=optotrak('DataGetNext3D',exp.coll.NumMarkers);                      
    curdata = cell2mat(data.Markers')';
    h(ai) = plot3(curdata(1,1),curdata(1,2),curdata(1,3),'.k');             % plot current position
    if ai>tail_len                                                          % routine to remove old samples and to keep h at tail_len length
        delete(h(1))
        h = circshift(h,[0 -1]);
%         for e =1:tail_len                                                 %this change color of dots according to their age 
%             set(h(e),'Color',[cols(e) cols(e) cols(e)])
%         end            
    else
        ai = ai+1;
    end
    pause(.05)
     if hypot(curdata(1,1)-exp.pos.(posfields{cont_flag})(1),...            % when the distance to the center of the target position is less than radius we add to a counter
             curdata(1,2)-exp.pos.(posfields{cont_flag})(2))<exp.pos.radius
         there = there+1;
     else                                                                   % and flush the counter if the marker to target distance is more than 1
         there = 0;
     end
     if there>minnum_samples                                                % when the counter is above the minimun number of sample we move to the next target position
         cont_flag = cont_flag+1;
     end
     delete(t)                                                              % removes the instruction text so it can be changed
     if cont_flag>size(posfields,1)                                         % all position have been checked
         cont_flag = 0;
         t = text(pl_len(2),pl_len(end-1),sprintf('Done. Thanks!'),'FontSize',14);
     end
end
pause(3)
close(gcf)

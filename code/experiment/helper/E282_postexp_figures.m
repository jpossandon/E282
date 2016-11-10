% Fast result

t=1:length(result.moveRT)
figure, hold on
h(1) = plot(t, result.trial_maxRT,'.k')
h(2) = plot(t(logical(result.trial_crossed)),result.moveRT(logical(result.trial_crossed)),'.','Color',[1 .8 .8]);
plot(t(isnan(result.correct)),result.moveRT(isnan(result.correct)),'.','Color',[.6 .6 .6]);
plot(t(result.correct==0 & result.trial_crossed==1),result.moveRT(result.correct==0 & result.trial_crossed==1),'.','Color',[1 0 0]);
h(3) = plot(t(~logical(result.trial_crossed(1:length(result.moveRT)))),result.moveRT(~logical(result.trial_crossed(1:length(result.moveRT)))),'.','Color',[.8 .8 1]);
plot(t(result.correct==0 & result.trial_crossed==0),result.moveRT(result.correct==0 & result.trial_crossed==0),'.','Color',[0 0 1]);

legend(h,{'RT limit','crossed','uncrossed'})
xlabel('trial')
ylabel('RT (s)')
title(sprintf('Subjects %s      %d trials',exp.sNstr,length(result.moveRT)))

figure
t=1
for b =1:exp.nBlocks
    subplot(2,ceil(exp.nBlocks/2),b)
    hold on
    for tr=t:t+exp.trial_per_block(b)-1
        if ~isempty(odata(tr).Markers)
        if result.trial_crossed(tr)==1
            if result.correct(tr)==1
                plot(odata(tr).Markers{1}(1,:),odata(tr).Markers{1}(2,:),'.','Color',[1 .8 .8],'MarkerSize',4);
            elseif result.correct(tr)==0
                plot(odata(tr).Markers{1}(1,:),odata(tr).Markers{1}(2,:),'.','Color',[1 0 0],'MarkerSize',4);
            end
        else
             if result.correct(tr)==1
                plot(odata(tr).Markers{1}(1,:),odata(tr).Markers{1}(2,:),'.','Color',[.8 .8 1],'MarkerSize',4);
            elseif result.correct(tr)==0
                plot(odata(tr).Markers{1}(1,:),odata(tr).Markers{1}(2,:),'.','Color',[0 0 1],'MarkerSize',4);
             end
        end
        axis([160 500 -20 400])
        end
    end
    t = t+exp.trial_per_block(b);
end
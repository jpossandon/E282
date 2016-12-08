%%
figure, hold on
plot(result.moveRT(result.trial_crossed & result.correct),...
    result.fixmoveRT(result.trial_crossed & result.correct),'.','color',[1 0 0])
plot(result.moveRT(result.trial_crossed & ~result.correct),...
    result.fixmoveRT(result.trial_crossed & ~result.correct),'.','color',[1 .8 .8])
plot(result.moveRT(~result.trial_crossed & result.correct),...
    result.fixmoveRT(~result.trial_crossed & result.correct),'.','color',[0 0 1])
plot(result.moveRT(~result.trial_crossed & ~result.correct),...
    result.fixmoveRT(~result.trial_crossed & ~result.correct),'.','color',[.8 .8 1])

%%
% Performance wrt latency between stimulation and movmement onset
% TODO N does not match
edges = -.1:.1:.6;
uncrossperf = []; crossperf = [];
uncrossN    = []; crossN    = [];
for e=1:length(edges)
    auxindx     = find(result.moveRT>=edges(e) & result.moveRT<edges(e)+.1 & ~result.trial_crossed); 
    
    if isempty(auxindx)
        uncrossperf(e) = NaN;
        uncrossN(e)   = 0;
    else
        uncrossN(e)   = length(auxindx);
        uncrossperf(e) = 100*sum(result.correct(auxindx))./length(auxindx);
    end
    auxindx     = find(result.moveRT>=edges(e) & result.moveRT<edges(e)+.1 & result.trial_crossed); 
     if isempty(auxindx)
         crossN(e)   = 0;
        crossperf(e) = NaN;
     else
         crossN(e)   = length(auxindx);
        crossperf(e)   = 100*sum(result.correct(auxindx))./length(auxindx);
     end
     
end

figure,hold on
axis([-.1 .7 0 100])

hline(50,':k')
vline(0,':k')
plot(edges+.05,crossperf,'o-r','LineWidth',2,'MarkerSize',12,'MarkerFaceColor',[1 1 1])
plot(edges+.05,uncrossperf,'o-b','LineWidth',2,'MarkerSize',12,'MarkerFaceColor',[1 1 1])
xlabel('Stim-Move dur')
ylabel('Performance (%)')

%%
%
edges = 0:.05:.35;
uncrossperf = []; crossperf = [];
uncrossN    = []; crossN    = [];
for e=1:length(edges)
    auxindx     = find(result.soa>=edges(e) & result.soa<edges(e)+.05 & ~result.trial_crossed); 
    
    if isempty(auxindx)
        uncrossperf(e) = NaN;
        uncrossN(e)   = 0;
    else
        uncrossN(e)   = length(auxindx);
        uncrossperf(e) = 100*sum(result.correct(auxindx))./length(auxindx);
    end
    auxindx     = find(result.soa>=edges(e) & result.soa<edges(e)+.05 & result.trial_crossed); 
     if isempty(auxindx)
         crossN(e)   = 0;
        crossperf(e) = NaN;
     else
         crossN(e)   = length(auxindx);
        crossperf(e)   = 100*sum(result.correct(auxindx))./length(auxindx);
     end
     
end

figure,hold on
axis([-.4 0 0 100])

hline(50,':k')
vline(0,':k')
plot(-(edges+.025),crossperf,'o-r','LineWidth',2,'MarkerSize',12,'MarkerFaceColor',[1 1 1])
plot(-(edges+.025),uncrossperf,'o-b','LineWidth',2,'MarkerSize',12,'MarkerFaceColor',[1 1 1])
xlabel('SOA')
ylabel('Performance (%)')

%%
% by soa and move
movintv  = .1;
edgesmov = -.1:movintv:.6;
soaintv  = .05;
edgessoa = 0:soaintv:.35;
for em = 1:length(edgesmov)
    for es = 1:length(edgessoa)
        auxindx     = find(result.soa>=edgessoa(es) & result.soa<edgessoa(es)+soaintv & ...
            result.moveRT>=edgesmov(em) & result.moveRT<edgesmov(em)+movintv & ~result.trial_crossed); 
        if isempty(auxindx)
            uncrossperf(em,es) = NaN;
            uncrossN(em,es)   = 0;
        else
            uncrossN(em,es)   = length(auxindx);
            uncrossperf(em,es) = 100*sum(result.correct(auxindx))./length(auxindx);
        end
        auxindx     = find(result.soa>=edgessoa(es) & result.soa<edgessoa(es)+soaintv & ...
            result.moveRT>=edgesmov(em) & result.moveRT<edgesmov(em)+movintv & result.trial_crossed); 
         if isempty(auxindx)
             crossN(em,es)   = 0;
            crossperf(em,es) = NaN;
         else
             crossN(em,es)   = length(auxindx);
            crossperf(em,es)   = 100*sum(result.correct(auxindx))./length(auxindx);
         end
    end
end

uncrosspcolor                   = nan(length(edgesmov)+1,length(edgessoa)+1);
uncrosspcolor(1:end-1,1:end-1)  = uncrossperf;
crosspcolor                     = nan(length(edgesmov)+1,length(edgessoa)+1);
crosspcolor(1:end-1,1:end-1)    = crossperf;

cmap        = cmocean('ice');
textcolor   = [1 0 0];

figure
set(gcf,'Position',[182 193 932 509])
subplot(1,2,1)
pcolor(-[edgessoa edgessoa(end)+soaintv],[edgesmov edgesmov(end)+movintv],uncrosspcolor)
for em = 1:length(edgesmov)
    for es = 1:length(edgessoa)
        if uncrossN(em,es)~=0
            if uncrossN(em,es)<10,xdif = .01;else xdif = .02;end
                text(-edgessoa(es)-xdif,edgesmov(em)+.011,num2str(uncrossN(em,es)),'Color',textcolor)
        end
    end
end
set(gca,'XTick',fliplr(-(edgessoa)),...
    'XTickLabels',fliplr(-(edgessoa)),...
    'YTick',edgesmov,...
    'YTickLabels',edgesmov)
caxis([50 100])
axis square
title('Uncrossed')
xlabel('SOA (s)')
ylabel('Stim-move (s)')
colorbar

subplot(1,2,2)

pcolor(-[edgessoa edgessoa(end)+soaintv],[edgesmov edgesmov(end)+movintv],crosspcolor)
for em = 1:length(edgesmov)
    for es = 1:length(edgessoa)
        if crossN(em,es)~=0
            if crossN(em,es)<10,xdif = .01;else xdif = .02;end
                text(-edgessoa(es)-xdif,edgesmov(em)+.011,num2str(crossN(em,es)),'Color',textcolor)
        end
    end
end
set(gca,'XTick',fliplr(-(edgessoa)),...
    'XTickLabels',fliplr(-(edgessoa)),...
    'YTick',edgesmov,...
    'YTickLabels',edgesmov)
caxis([50 100])
colorbar
colormap(cmap)
axis square
title('Crossed')
xlabel('SOA (s)')
ylabel('Stim-move (s)')

% tightfig

%%
% trajectories
load('/Users/jossando/trabajo/E282/data/s4_sfix/s4_sfix_results.mat')
load('/Users/jossando/trabajo/E282/data/s4_sfix/s4_sfix_odata.mat')
figure
set(gcf,'Position',[1 1 1280 704])
edges = -.1:.1:.6;
for e=1:length(edges)
    subplot(2,8,e),hold on
    auxindx     = find(result.moveRT>=edges(e) & result.moveRT<edges(e)+.1 & ~result.trial_crossed); 
    for auxt = 1:length(auxindx)
        if result.correct(auxindx(auxt))==1
            plot(odata(auxindx(auxt)).Markers{1}(1,1:2:end),odata(auxindx(auxt)).Markers{1}(2,1:2:end),'.','Color',[1 .8 .8],'MarkerSize',4);
        elseif result.correct(auxindx(auxt))==0
            plot(odata(auxindx(auxt)).Markers{1}(1,1:2:end),odata(auxindx(auxt)).Markers{1}(2,1:2:end),'.','Color',[1 0 0],'MarkerSize',4);
        end
    end
    axis([160 500 -20 400])
    title(sprintf('stim-mov %1.3f s',edges(e)+.05))
     subplot(2,8,e+8),hold on
    auxindx     = find(result.moveRT>=edges(e) & result.moveRT<edges(e)+.1 & result.trial_crossed); 
    for auxt = 1:length(auxindx)
        if result.correct(auxindx(auxt))==1
            plot(odata(auxindx(auxt)).Markers{1}(1,1:2:end),odata(auxindx(auxt)).Markers{1}(2,1:2:end),'.','Color',[.8 .8 1],'MarkerSize',4);
        elseif result.correct(auxindx(auxt))==0
            plot(odata(auxindx(auxt)).Markers{1}(1,1:2:end),odata(auxindx(auxt)).Markers{1}(2,1:2:end),'.','Color',[0 0 1],'MarkerSize',4);
        end
    end
    axis([160 500 -20 400])
    title(sprintf('stim-mov %1.3f s',edges(e)+.05))
end

%     
% for b =1:exp.nBlocks
%     subplot(2,ceil(exp.nBlocks/2),b)
%     hold on
%     for tr=t:t+exp.trial_per_block(b)-1
%         if ~isempty(odata(tr).Markers)
%         if result.trial_crossed(tr)==1
%             if result.correct(tr)==1
%                 plot(odata(tr).Markers{1}(1,:),odata(tr).Markers{1}(2,:),'.','Color',[1 .8 .8],'MarkerSize',4);
%             elseif result.correct(tr)==0
%                 plot(odata(tr).Markers{1}(1,:),odata(tr).Markers{1}(2,:),'.','Color',[1 0 0],'MarkerSize',4);
%             end
%         else
%              if result.correct(tr)==1
%                 plot(odata(tr).Markers{1}(1,:),odata(tr).Markers{1}(2,:),'.','Color',[.8 .8 1],'MarkerSize',4);
%             elseif result.correct(tr)==0
%                 plot(odata(tr).Markers{1}(1,:),odata(tr).Markers{1}(2,:),'.','Color',[0 0 1],'MarkerSize',4);
%              end
%         end
%         axis([160 500 -20 400])
%         end
%     end
%     t = t+exp.trial_per_block(b);
% end
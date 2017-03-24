%win.trial_trigger = win.trial_trigger(1:4449) %s03
trial_trigger = win.trial_trigger(find(win.trial_trigger==10 | win.trial_trigger==13 | win.trial_trigger==18 | win.trial_trigger==21));
SOAs          = win.trial_tactsoa(find(win.trial_trigger==10 | win.trial_trigger==13 | win.trial_trigger==18 | win.trial_trigger==21)); 
SOAs(trial_trigger == 13 | trial_trigger == 21) = -SOAs(trial_trigger == 13 | trial_trigger == 21); 
response      = win.response; 

perf = [];
for ss = unique(SOAs)
    for tt = unique(trial_trigger(SOAs==ss))
    
        perf = [perf; [tt ss sum(response(find(trial_trigger==tt & SOAs==ss))==2)./length(response(find(trial_trigger==tt & SOAs==ss))) sum(response(find(trial_trigger==tt & SOAs==ss))==2) length(response(find(trial_trigger==tt & SOAs==ss)))]];
    length(response(find(trial_trigger==tt & SOAs==ss)))
    end
end

%%
[lC_unc,dev_unc,stat] = glmfit(perf(perf(:,1)==10 | perf(:,1)==13,2),[perf(perf(:,1)==10 | perf(:,1)==13,4) perf(perf(:,1)==10 | perf(:,1)==13,5)],'binomial','logit');
[logitFit_unc logitFit_unc_lo logitFit_unc_hi] = glmval(lC_unc,-1.8:.1:1.8,'logit',stat);

[lC_c,dev_c,stat] = glmfit(perf(perf(:,1)==18 | perf(:,1)==21,2),[perf(perf(:,1)==18 | perf(:,1)==21,4) perf(perf(:,1)==18 | perf(:,1)==21,5)],'binomial','logit');
[logitFit_c logitFit_c_lo logitFit_c_hi] = glmval(lC_c,-1.8:.1:1.8,'logit',stat);

%TODO se
figure,hold on
vline(0,'k--')
hline(.5,'k--')
h(1) = plot(perf(perf(:,1)==10 | perf(:,1)==13,2),perf(perf(:,1)==10 | perf(:,1)==13,3),'ok','MarkerSize',10)
plot(-1.8:.1:1.8,logitFit_unc,'k','LineWidth',2)
plot(-1.8:.1:1.8,logitFit_unc+logitFit_unc_hi,'b:')
plot(-1.8:.1:1.8,logitFit_unc-logitFit_unc_lo,'b:')
% jbfill(perf(perf(:,1)==10 | perf(:,1)==13,2),logitFit_unc+logitFit_unc_hi,logitFit_unc-logitFit_unc_lo ,[0 0 1],[1 0 0],0,1)

h(2) = plot(perf(perf(:,1)==18 | perf(:,1)==21,2),perf(perf(:,1)==18 | perf(:,1)==21,3),'or','MarkerSize',10)
plot(-1.8:.1:1.8,logitFit_c,'r','LineWidth',2)
plot(-1.8:.1:1.8,logitFit_c+logitFit_c_hi,'r:')
plot(-1.8:.1:1.8,logitFit_c-logitFit_c_lo,'r:')
ylabel('% Right')
legend(h,{'Uncross','Cross'},'Location','NorthWest')

%%
rangeI = 0:.005:.2;
indxData = q.trialCount;
[lC_unc,dev_unc,stat] = glmfit(10.^q.intensity(1:indxData)',q.response(1:indxData)','binomial','logit');
[logitFit_unc logitFit_unc_lo logitFit_unc_hi] = glmval(lC_unc,rangeI ,'logit',stat);

%TODO se
figure,hold on
% vline(0,'k--')
%hline(.5,'k--')
h(1) = plot(10.^q.intensity(1:indxData)',q.response(1:indxData)','ok','MarkerSize',6)
plot(rangeI ,logitFit_unc,'r','LineWidth',2)
xlim([0 rangeI(end)])


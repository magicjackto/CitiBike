% %%
% load('hourlydataall.mat');
% %% regressor setup
% % hour indicator
% hours = repmat([1:24],1,days)';
% hoursind = dummyvar(hours);
% % weekdayind 1 for weekday and 0 for weekend
% weekdayind = ~(weekind == 1 | weekind == 7);
% % plot total bikes
% figure;
% plot(totalbike)
% xlabel('hour')
% ylabel('totalbikes')
% % plot total bike vs temp hourly
% figure;
% for i = 1:24
%     subplot(4,6,i)
%     plot(totalbike(hours == i & weekdayind == 1), newtemp(hours == i & weekdayind == 1),'.');
% end
% figure;
% plot(hours,newtemp,'.')
% %% total number regression 1
% % divide into training and test
% [trainInd1,~,testInd1] = divideint(size(totalbike,1),0.8,0,0.2);
% x1 = [newtemp(:,1), hoursind, weekdayind];
% [r1,~,~,~,stats1] = regress(totalbike(trainInd1,1),x1(trainInd1,:));
% % r^2 and adjusted r^2
% rs1 = stats1(1);
% ars1 = rs1 - (1-rs1)*(size(x1,2)-1)/((size(x1,1)-size(x1,2)));
% % MSE
% msesample = mean((totalbike(trainInd1,1) - x1(trainInd1,:)*r1).^2);
% msetest = mean((totalbike(testInd1,1) - x1(testInd1,:)*r1).^2);
% 
% y1hat = x1(testInd1,:)*r1;
% % qq plot
% figure;
% qqplot(y1hat,totalbike(testInd1,1));
% % sample plot
% figure;
% plot(totalbike(trainInd1,1));
% hold on;
% plot(x1(trainInd1,:)*r1);
% hold off;
% legend('triandata','fit');
% xlabel('hours')
% ylabel('totalbikes')
% title('trianing fit original')
% % test plot
% figure;
% plot(totalbike(testInd1,1));
% hold on;
% plot(x1(testInd1,:)*r1);
% hold off;
% legend('testdata','prediction');
% xlabel('hours')
% ylabel('totalbikes')
% title('test fit original')
% %% total number regression 2
% % divide into training and test
% [trainInd1,~,testInd1] = divideint(size(totalbike,1),0.8,0,0.2);
% x1 = [newtemp, hoursind, weekdayind];
% [r1,~,~,~,stats1] = regress(totalbike(trainInd1,1),x1(trainInd1,:));
% % r^2 and adjusted r^2
% rs1 = stats1(1);
% ars1 = rs1 - (1-rs1)*(size(x1,2)-1)/((size(x1,1)-size(x1,2)));
% % MSE
% msesample = mean((totalbike(trainInd1,1) - x1(trainInd1,:)*r1).^2);
% msetest = mean((totalbike(testInd1,1) - x1(testInd1,:)*r1).^2);
% 
% y1hat = x1(testInd1,:)*r1;
% % qq plot
% figure;
% qqplot(y1hat,totalbike(testInd1,1));
% % sample plot
% figure;
% plot(totalbike(trainInd1,1));
% hold on;
% plot(x1(trainInd1,:)*r1);
% hold off;
% legend('triandata','fit');
% xlabel('hours')
% ylabel('totalbikes')
% title('trianing fit new')
% % test plot
% figure;
% plot(totalbike(testInd1,1));
% hold on;
% plot(x1(testInd1,:)*r1);
% hold off;
% legend('testdata','prediction');
% xlabel('hours')
% ylabel('totalbikes')
% title('test fit new')
%% in/out flow
flow = inbike-outbike;
% select k random sets
kk = 10;
oosLossIndividual = NaN(kk,1);
% rndidx = NaN(k,1);
% for i = 1:kk
%     rndidx(i,1) = floor(unifrnd(1,498));
% end
rs22 = NaN(kk,1);
ars22 = NaN(kk,1);
for i = 1:kk
    indx1 = rndidx(i,1);
    flow1 = flow(:,indx1);

    % histgram index 1
    % hist(flow1, 50)

%     for i = 1:24
%         subplot(4,6,i)
%         plot(flow1(hours == i & weekdayind == 1), newtemp(hours == i & weekdayind == 1),'.');
%     end

    %% in/out flow regeression
    % divide into training and test
    [trainInd2,~,testInd2] = divideint(size(flow1,1),0.8,0,0.2);
    x21 = [newtemp, hoursind, weekdayind];
    [r21,~,~,~,stats21] = regress(flow1(trainInd2,1),x21(trainInd2,:));
    y21hat = x21(testInd2,:)*r21;
    y1hat = x1(testInd1,:)*r1;
    % r^2 and adjusted r^2
    rs22(i,1) = stats21(1);
    ars22(i,1) = rs22(i,1) - (1-rs22(i,1))*(size(x21,2)-1)/((size(x21,1)-size(x21,2)));
%     % qq plot
%     figure;
%     qqplot(y1hat,totalbike(testInd1,1));
%     % sample plot
%     figure;
%     plot(flow1(trainInd2,1));
%     hold on;
%     plot(x21(trainInd2,:)*r21);
%     hold off;
%     legend('triandata','fit');
%     % test plot
%     figure;
%     plot(flow1(testInd2,1));
%     hold on;
%     plot(x21(testInd2,:)*r21);
%     hold off;
%     legend('testdata','prediction');

    %% SVM
    flowind1 = double(flow1>0) - double(flow1 <-0);
    % hist(flowind1)
    T = table(hours, weekind, newtemp(:,1),newtemp(:,2),newtemp(:,3));
    t = templateSVM('Standardize',1);
    Mdl = fitcecoc(T,flowind1,'Learners',t);
    CVMdl = crossval(Mdl);
    oosLossIndividual(i,1) = kfoldLoss(CVMdl);
end
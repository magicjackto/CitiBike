% station locations
stationloc = NaN(stationnum,2);
for i = 1:stationnum
    stationidx = find(startstationid == stationid(i), 1);
    stationloc(i,1) = startstationlongitude(i,1);
    stationloc(i,2) = startstationlatitude(i,1);
end

%% clustring
kset = [10:30];
acoh = NaN(length(kset), 1);
asep = NaN(length(kset), 1);
for i = 1:length(kset)
    [~, C, sumd] = kmeans(stationloc, kset(i));
    acoh(i,1) = sum(sumd) / kset(i);
    tempsum = 0;
    tempcount = 0;
    for ii = 1:(kset(i)-1)
        for iii = (ii+1):kset(i)
            tempsum = tempsum + sqrt( (C(ii, 1) - C(iii,1))^2 + (C(ii, 2) - C(iii,2))^2);
            tempcount = tempcount + 1;
        end
    end
    asep(i,1) = tempsum / tempcount;
end
figure();
plot(kset, acoh, 'r');
xlabel('k')
ylabel('average cohesion within clusters')
title('average cohesion witin clusters')
figure();
plot(kset, asep,'b')
xlabel('k')
ylabel('average seperation within clusters')
title('average seperation witin clusters')

%% choose k
k = 18;

groups = kmeans(stationloc, k);

figure();
hold on;
for i = 1:k
    plot(stationloc(groups==i,1), stationloc(groups==i,2),'o');
end
hold off;
legend('1','2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18');
xlabel('longitude')
ylabel('latitude')
title('clustering of stations')

%% re-do in/out regression
% load data
load('hourlydataall.mat');

%% in/out
flow = inbike-outbike;
groupflow = NaN(size(flow, 1), k);
for i = 1:k
    groupflow(:,i) = sum(flow(:,groups==i),2);
end
oosLossGroup = NaN(k,1);
rs21 = NaN(k,1);
ars21 = NaN(k,1);
for i = 1:k
    flow1 = groupflow(:,i);

%     histgram index 1
%     hist(flow1, 30)

%     for i = 1:24
%         subplot(4,6,i)
%         plot(flow1(hours == i & weekdayind == 1), newtemp(hours == i & weekdayind == 1),'.');
%     end
    % divide into training and test
%     [trainInd2,~,testInd2] = divideint(size(flow1,1),0.8,0,0.2);
%     x21 = [newtemp, hoursind, weekdayind];
%     [r21,~,~,~,stats21] = regress(flow1(trainInd2,1),x21(trainInd2,:));
%     y21hat = x21(testInd2,:)*r21;
%     y1hat = x1(testInd1,:)*r1;
%     % r^2 and adjusted r^2
%     rs21(i,1) = stats21(1);
%     ars21(i,1) = rs21(i,1) - (1-rs21(i,1))*(size(x21,2)-1)/((size(x21,1)-size(x21,2)));
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

    % SVM
    flowind1 = double(flow1>6) - double(flow1 <-6);
    %hist(flowind1)
    T = table(hours, weekind, newtemp(:,1),newtemp(:,2),newtemp(:,3));
    t = templateSVM('Standardize',1);
    Mdl = fitcecoc(T,flowind1,'Learners',t);
    CVMdl = crossval(Mdl);
    oosLossGroup(i) = kfoldLoss(CVMdl)
end
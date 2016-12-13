%%
% load bike data
load('bikedataall.mat');
% load temperature data
load('tempdata.mat');

bikeid = bikeid(1:end);
birthyear = birthyear(1:end);
endstationid = endstationid(1:end);
endstationlatitude = endstationlatitude(1:end);
endstationlongitude = endstationlongitude(1:end);
gender = gender(1:end);
startstationid = startstationid(1:end);
startstationlatitude = startstationlatitude(1:end);
startstationlongitude = startstationlongitude(1:end);
starttime = starttime(1:end);
stoptime = stoptime(1:end);
tripduration = tripduration(1:end);
usertype = usertype(1:end);
%%
% days used
days = 365;
% start month
startmonth = 1;
% unique stations
stationid = unique([startstationid; endstationid]);
stationnum = size(stationid,1);
% hourly time
totalhour = days*24;
totalbike = zeros(totalhour,1);
inbike = zeros(totalhour,stationnum);
outbike = zeros(totalhour,stationnum);
newtemp = zeros(totalhour,3);
weekind = zeros(totalhour,1);
%datahour = hour(starttime);
%time0 = datenum(2015,1,1,0,0,0);
% write data in matrix
for i = 1:totalhour
    totalbike(i) = sum((datenum(2015,startmonth,1,i,0,0)>=datenum(starttime) & datenum(stoptime)>=datenum(2015,startmonth,1,i-1,0,0)));
    outind = (datenum(2015,startmonth,1,i-1,0,0)<=datenum(starttime) & datenum(starttime)<datenum(2015,startmonth,1,i,0,0));
    inind = (datenum(2015,startmonth,1,i-1,0,0)<=datenum(stoptime) & datenum(stoptime)<datenum(2015,startmonth,1,i,0,0));
    for j = 1:stationnum
        inbike(i,j) = sum(startstationid(inind)==stationid(j));
        outbike(i,j) = sum(startstationid(outind)==stationid(j));
    end
    % store the first hourly temp information into newtemp
    tempind = datenum(2015,startmonth,1,i-1,0,0)<=datenum(YRMODAHRMN) & datenum(YRMODAHRMN)<datenum(2015,startmonth,1,i,0,0);
    foundtemp1 = 0;
    foundtemp2 = 0;
    foundtemp3 = 0;
    tempTEMP = TEMP(tempind);
    tempSPD = SPD1(tempind);
    tempPCP = PCP1(tempind);
    for j = 1:size(YRMODAHRMN(tempind),1)
        if ~isnan(tempTEMP(j))
            foundtemp1 = 1;
            newtemp(i,1) = tempTEMP(j);
        end
        if ~isnan(tempSPD(j))
            foundtemp2 = 1;
            newtemp(i,2) = tempSPD(j);
        end
        if ~isnan(tempPCP(j))
            foundtemp3 = 1;
            newtemp(i,3) = tempPCP(j);
        end
    end
    % if no temp information that hour, use the last information
    if foundtemp1 == 0
        newtemp(i,1) = newtemp(i-1,1);
    end
    if foundtemp2 == 0
        newtemp(i,2) = newtemp(i-1,2);
    end
    if foundtemp3 == 0
        newtemp(i,3) = newtemp(i-1,3);
    end
    % store the weekday information into weekind 1 for Sun and 7 for Sat
    weekind(i) = weekday((datenum(2015,startmonth,1,i,0,0)));
    i
end
save('hourlydataall.mat');
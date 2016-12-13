%% read data
filename2015 = cell(12,1);
for i = 1:9
    filename2015(i) = cellstr(['20150' num2str(i) '-citibike-tripdata.csv']);
end
for i = 10:12
    filename2015(i) = cellstr(['2015' num2str(i) '-citibike-tripdata.csv']);
end
bikeid = [];
birthyear = [];
endstationid = [];
endstationlatitude = [];
endstationlongitude = [];
gender = [];
startstationid = [];
startstationlatitude = [];
startstationlongitude = [];
starttime = [];
stoptime = [];
tripduration = [];
usertype = [];
typeind = [1,2,3,6];
[bikeid, birthyear, endstationid, endstationlatitude, endstationlongitude, gender, startstationid, ...
        startstationlatitude, startstationlongitude, starttime, stoptime, tripduration, usertype] = ReadCitiFile1(pwd, filename2015(1));
for i = 2:12
    if any(i==typeind)
        [bikeid2, birthyear2, endstationid2, endstationlatitude2, endstationlongitude2, gender2, startstationid2, ...
            startstationlatitude2, startstationlongitude2, starttime2, stoptime2, tripduration2, usertype2] = ReadCitiFile1(pwd, filename2015(i));
    else
        [bikeid2, birthyear2, endstationid2, endstationlatitude2, endstationlongitude2, gender2, startstationid2, ...
            startstationlatitude2, startstationlongitude2, starttime2, stoptime2, tripduration2, usertype2] = ReadCitiFile2(pwd, filename2015(i));
    end
    bikeid = [bikeid; bikeid2];
    birthyear = [birthyear; birthyear2];
    endstationid = [endstationid; endstationid2];
    endstationlatitude = [endstationlatitude; endstationlatitude2];
    endstationlongitude = [endstationlongitude; endstationlongitude2];
    gender = [gender; gender2];
    startstationid = [startstationid; startstationid2];
    startstationlatitude = [startstationlatitude; startstationlatitude2];
    startstationlongitude = [startstationlongitude; startstationlongitude2];
    starttime = [starttime; starttime2];
    stoptime = [stoptime; stoptime2];
    tripduration = [tripduration; tripduration2];
    usertype = [usertype; usertype2];
    i
end
clearvars bikeid2 birthyear2 endstationid2 endstationlatitude2 endstationlongitude2 gender2 startstationid2 ...
    startstationlatitude2 startstationlongitude2 starttime2 stoptime2 tripduration2 usertype2
save('bikedataall.mat');

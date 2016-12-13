function [bikeid, birthyear, endstationid, endstationlatitude, endstationlongitude, gender, startstationid, ...
    startstationlatitude, startstationlongitude, starttime, stoptime, tripduration, usertype] = ReadCitiFile1(path, filename)
%% Import data from text file.
% Script for importing data from the following text file:
%
%    /Users/xienliu/Dropbox/2015/201512-citibike-tripdata.csv
%
% To extend the code to different selected data or a different text file,
% generate a function instead of a script.

% Auto-generated by MATLAB on 2016/11/28 10:58:23

%% Initialize variables.
filename = [path '/' char(filename)];
delimiter = ',';
startRow = 2;

%% Read columns of data as text:
% For more information, see the TEXTSCAN documentation.
formatSpec = '%s%s%s%s%*s%s%s%s%*s%s%s%s%s%s%s%[^\n\r]';

%% Open the text file.
fileID = fopen(filename,'r');

%% Read columns of data according to the format.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');

%% Close the text file.
fclose(fileID);

%% Convert the contents of columns containing numeric text to numbers.
% Replace non-numeric text with NaN.
raw = repmat({''},length(dataArray{1}),length(dataArray)-1);
for col=1:length(dataArray)-1
    raw(1:length(dataArray{col}),col) = dataArray{col};
end
numericData = NaN(size(dataArray{1},1),size(dataArray,2));

for col=[1,4,5,6,7,8,9,10,12,13]
    % Converts text in the input cell array to numbers. Replaced non-numeric
    % text with NaN.
    rawData = dataArray{col};
    for row=1:size(rawData, 1);
        % Create a regular expression to detect and remove non-numeric prefixes and
        % suffixes.
        regexstr = '(?<prefix>.*?)(?<numbers>([-]*(\d+[\,]*)+[\.]{0,1}\d*[eEdD]{0,1}[-+]*\d*[i]{0,1})|([-]*(\d+[\,]*)*[\.]{1,1}\d+[eEdD]{0,1}[-+]*\d*[i]{0,1}))(?<suffix>.*)';
        try
            result = regexp(rawData{row}, regexstr, 'names');
            numbers = result.numbers;
            
            % Detected commas in non-thousand locations.
            invalidThousandsSeparator = false;
            if any(numbers==',');
                thousandsRegExp = '^\d+?(\,\d{3})*\.{0,1}\d*$';
                if isempty(regexp(numbers, thousandsRegExp, 'once'));
                    numbers = NaN;
                    invalidThousandsSeparator = true;
                end
            end
            % Convert numeric text to numbers.
            if ~invalidThousandsSeparator;
                numbers = textscan(strrep(numbers, ',', ''), '%f');
                numericData(row, col) = numbers{1};
                raw{row, col} = numbers{1};
            end
        catch me
        end
    end
end

dateFormatIndex = 1;
blankDates = cell(1,size(raw,2));
anyBlankDates = false(size(raw,1),1);
invalidDates = cell(1,size(raw,2));
anyInvalidDates = false(size(raw,1),1);
for col=[2,3]% Convert the contents of columns with dates to MATLAB datetimes using the specified date format.
    try
        dates{col} = datetime(dataArray{col}, 'Format', 'MM/dd/yy HH:mm', 'InputFormat', 'MM/dd/yy HH:mm'); %#ok<SAGROW>
    catch
        try
            % Handle dates surrounded by quotes
            dataArray{col} = cellfun(@(x) x(2:end-1), dataArray{col}, 'UniformOutput', false);
            dates{col} = datetime(dataArray{col}, 'Format', 'MM/dd/yy HH:mm', 'InputFormat', 'MM/dd/yy HH:mm'); %%#ok<SAGROW>
        catch
            dates{col} = repmat(datetime([NaN NaN NaN]), size(dataArray{col})); %#ok<SAGROW>
        end
    end
    
    dateFormatIndex = dateFormatIndex + 1;
    blankDates{col} = cellfun(@isempty, dataArray{col});
    anyBlankDates = blankDates{col} | anyBlankDates;
    invalidDates{col} = isnan(dates{col}.Hour) - blankDates{col};
    anyInvalidDates = invalidDates{col} | anyInvalidDates;
end
dates = dates(:,[2,3]);
blankDates = blankDates(:,[2,3]);
invalidDates = invalidDates(:,[2,3]);

%% Split data into numeric and cell columns.
rawNumericColumns = raw(:, [1,4,5,6,7,8,9,10,12,13]);
rawCellColumns = raw(:, 11);


%% Replace non-numeric cells with NaN
R = cellfun(@(x) ~isnumeric(x) && ~islogical(x),rawNumericColumns); % Find non-numeric cells
rawNumericColumns(R) = {NaN}; % Replace non-numeric cells

%% Allocate imported array to column variable names
tripduration = cell2mat(rawNumericColumns(:, 1));
starttime = dates{:, 1};
stoptime = dates{:, 2};
startstationid = cell2mat(rawNumericColumns(:, 2));
startstationlatitude = cell2mat(rawNumericColumns(:, 3));
startstationlongitude = cell2mat(rawNumericColumns(:, 4));
endstationid = cell2mat(rawNumericColumns(:, 5));
endstationlatitude = cell2mat(rawNumericColumns(:, 6));
endstationlongitude = cell2mat(rawNumericColumns(:, 7));
bikeid = cell2mat(rawNumericColumns(:, 8));
usertype = rawCellColumns(:, 1);
birthyear = cell2mat(rawNumericColumns(:, 9));
gender = cell2mat(rawNumericColumns(:, 10));

% For code requiring serial dates (datenum) instead of datetime, uncomment
% the following line(s) below to return the imported dates as datenum(s).

% starttime1=datenum(starttime1);
% stoptime1=datenum(stoptime1);


end
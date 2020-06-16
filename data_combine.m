%% COMBINING NEM and BOM Data
% David Willingham 2011
%% Importing NEM and BOM Data
[dates3,airtemp2,wetbulb2,dewpnt2,humidity2] = process_temp_data;
[dates,dates2, demand, rrp] = process_nem_data;

%% Converting to structure format
date = cellstr(datestr(dates2,'dd/mm/yy'));
[~,~,~,hour,min] = datevec(dates2);
hour = hour+min/60;
data.Date = date;
data.Hour = hour;
data.DryBulb = airtemp2;
data.DewPnt = dewpnt2;
data.SYSLoad = demand;
data.NumDate = dates2;
data.WetBulb = wetbulb2;
data.Humidity = humidity2;
data.ElecPrice = rrp;

dataexcel = [date,num2cell([hour,airtemp2,dewpnt2,wetbulb2,humidity2,rrp,demand])];
header = {'Date','Hour','DryBulb','DewPnt','WetBulb','Humidity','ElecPrice','SYSLoad'};
dataexcel = [header;dataexcel];
%% Saving data to MAT and Excel file
save ausdata data
xlswrite('ausdata.xlsx', dataexcel)

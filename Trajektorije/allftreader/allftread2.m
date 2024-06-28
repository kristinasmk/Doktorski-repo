function [AC,ACintent] = allftread2 (raw_allft, desired_time, endtime)

raw_allft = '20210901Initial.ALL_FT+';
desired_time = 8*3600;
endtime = 10*3600;

%this function will read raw *.ALL_FT+ file obtained from NEST and filter
%desired data.
%output of allftread function will be struct of all data sorted per aircraft id
% and structure of data sorted per aircraft id from desired time till end
% of logged data
%and each aircraft will have:
%   Callsign
%   Departure airport (4-letter ICAO code)
%   Destination airport (4-letter ICAO code)
%   planned route (list of x,y,z coordinates

%function to import *.all_ft+ data from NEST
allftdata=import_allft(raw_allft);
allftdata=allftdata(2:end,:);
%prikazivati strukturu, odnosno 

%creation of unique ACid which is same for so6 data so it can be matched
ACid=cellstr([char(allftdata(:,1)),char(allftdata(:,2)),char(allftdata(:,3))]);

%selecting of cleared route points from all_ft+ data
croute=allftdata(:,86);

%creating empty structure
AC(numel(croute))=struct();
n=1;  %counter for ACintetnt list
%iz nekog razloga, struktura se ne želi prikazati ako nema nultog reda
ACintent=struct();

 eobt_raw = allftdata(:, 18);
    eobt = zeros(size(eobt_raw));
    for i = 1:numel(eobt_raw)
        % Convert to string and then extract
        eobt_str = string(eobt_raw{i});  % Convert cell to string
        eobt_num = str2double(eobt_str);  % Convert string to numerical value
        
        % Convert numerical value to string
        eobt_str_formatted = sprintf('%012.0f', eobt_num);  % Ensure 12 digits for YYYYMMDDHHMMSS
        time_str = eobt_str_formatted(end-5:end);  % Extract HHMMSS part
        
        % Calculate time in seconds
        eobt(i) = str2double(time_str(1:2)) * 3600 + str2double(time_str(3:4)) * 60 + str2double(time_str(5:6));
    end

for s=1:numel(croute)
     if numel(char(croute(s)))>0
%spliting each logged point
newStr=split(string(croute(s)),' '); %splitting route points, delimiter Space               
newStr=split(newStr,':'); %splitting route elements, delimiter ':'
t=char(newStr(:,1));       %cutting time from YYYYMMDDHHMMSS to HHMMSS
dat=[str2num(t(:,5:6)),str2num(t(:,7:8))]; 
t=time_conv(t(:,end-5:end)); %converting HHMMSS to time in seconds SSSSS
t=[t,dat];
coords=char(newStr(:,7));   %extracting coords
coords=coord_conv(coords); %splitting coordis
froute=rfilter(newStr);    %removing automatic generated points marked with ! or *


%log every route data to AC structure
AC(s).ACid=ACid(s);
AC(s).callsing=allftdata(s,3);
AC(s).depart=allftdata(s,1);
AC(s).dest=allftdata(s,2);
AC(s).route_raw=cellstr(newStr);
AC(s).ts=t;
AC(s).coords=cellstr(coords);
AC(s).froute=cellstr(froute);
AC(s).eobt = eobt(s);

%loging desired data from desired point in time "desired_time"
        if desired_time<=t(size(t,1),1) && endtime >= t(1,1)  %determing if route is within desired time
            p=sum(~(desired_time<=t(:,1)))+1; %determing point od desired time in route
            %+1 is addes to rule out route point before desired_time
            ACintent(n).ACid=ACid(s); 
            ACintent(n).callsing=allftdata(s,3);
            ACintent(n).depart=allftdata(s,1);
            ACintent(n).route=cellstr(newStr);
            ACintent(n).ts=t(:,1);
            ACintent(n).coords=cellstr(coords);
%             raw_route=newStr(p:end,:);
%             raw_route=newStr(s);
%             froute=rfilter(raw_route);
            fcoords=char(froute(:,7));
            fcoords=coord_conv(fcoords);
            ACintent(n).froute=[cellstr(froute),cellstr(fcoords)];
            y=str2double(ACintent(n).froute(:,10));
            ns=char(ACintent(n).froute(:,11))=='S';
            y(ns)=y(ns)*-1;
            x=str2double(ACintent(n).froute(:,12));
            we=char(ACintent(n).froute(:,13))=='W';
            x(we)=x(we)*-1;
            ACintent(n).waypoints.y=y;
            ACintent(n).waypoints.x=x;
            ACintent(n).waypoints.z=str2double(ACintent(n).froute(:,4))*100*0.3048;
            ACintent(n).waypoints.flyover=zeros(size(ACintent(n).froute,1),1);
            ACintent(n).eobt = eobt(s);
            n=n+1;
            
        end


     end
end

% save('ACintent.mat', 'ACintent');
% save('AC', 'AC'); 
%---------------------
%important notice
%---------------------
% flights that start od D-1 are also taken by mistake into account because
% time starts from 0 on day D. This will not be tackled at the moment
% because number of night flights is not so high to cause complexity
% problems
%---------------------

 end
 
function [flight, flight_pos] = so6reader_test (raw_so6,desired_time)
% this is code for raw data processing, input will be raw s06 obtained for
% desired date in speciffic time period. Output of this code will be
% table where each row represent state of aircraft in stated time. State of
% aircraft consider:
%
%   x,y,z coordinates(x - E/W position,y - N/S position,z - altitude in m), 
%   GS (m/s),
%   TK (degs DDD.d math notations),
%   ACtype,
%   Callsign
%
% inputs to this function are raw so6 data obtained from NEST and desired 
% time set by user
% raw so6 should be stated as string (example '20171007test2.so6')
% desired time should be in form of seconds
%date should be in input in form of YYMMDD double
%
%output flight is complete so6 data sorted per flight ID, and flight_pos is
%list aircraft that are flying in the moment "desired time".

so6data=import_so6(raw_so6);   %funkction for importing of raw so6


etime=so6data(:,5);         %filtering of time at enter of segment
dtime=so6data(:,6);         %filtering of time at depart of segment

%current time is logged as hhmmss and should be converted to seconds
%for conversin is ceated time_conv function
etime_sec=time_conv(etime);
dtime_sec=time_conv(dtime);

etime_sec=num2cell(etime_sec);%time is double and should be cell for merge 
dtime_sec=num2cell(dtime_sec);
so6data=[so6data,etime_sec,dtime_sec]; %adding row with time in seconds to so6 data

%since some callsings are repetative flights new unique ID has to be created to 
ACid=cellstr([char(so6data(:,2)),char(so6data(:,3)),char(so6data(:,10))]); 
% should be differentiate by AC ID given from eurocontrol
so6data=[so6data,ACid];
ACid=unique(ACid);

 n=1;           %this is counter for all matching ac to desired time to avoid gaps
% sortiranje podataka po zrakoplovu
for ac=1:numel(ACid)
    
    %this part of code sort so6 data in structure per aircraft callsign
    acfind=strcmp(so6data(:,23),ACid(ac));
    acpos=find(acfind>0);
    acdata=so6data(acpos,:);
    flight(ac).name=ACid{ac}; %ac callsign
    flight(ac).data=acdata;  %so6 data
    time=cell2mat(acdata(:,21:22));
    flight(ac).time=time;   %time  segment of entering and departing
    

 
    %tris part of code work only when desired time for ac position is
    %withing flight time of aircraft, in any other conditions ac will be
    %skipped
    if desired_time>=time(1,1) && desired_time<=time(size(time,1),2)  
      
       a=sum(time(:,1)<desired_time); % a determines position of flight segment
       %                                in desired time
       koef=(desired_time-time(a,1))/(time(a,2)-time(a,1)); %koeficient for interpolation of positin
        flight_pos(n).name=ACid{ac}; %ac callsign
        flight_pos(n).type=acdata(a,4);
        
        flight_pos(n).callsign=acdata(a,10); %adding callsing
        
        x=cell2mat([acdata(a,13),acdata(a,15)]); % extracting lat at start and end of segment
        xpos=x(1)+koef*(x(2)-x(1));              %determing lat position based on time koef
        flight_pos(n).xpos=xpos/60; %x latitude coord in form DD.dddddd
        
        y=cell2mat([acdata(a,14),acdata(a,16)]); % extracting lon at start and end of segment
        ypos=y(1)+koef*(y(2)-y(1));  %determing lon position based on time koef
        flight_pos(n).ypos=ypos/60; %y longitude coord in form DDD.dddddd
        
        z=cell2mat([acdata(a,7),acdata(a,8)]); % extracting altitude at start and end of segment
        zpos=z(1)+koef*(z(2)-z(1)); %determing altitude position based on time koef
        flight_pos(n).zpos=FLtoM(zpos); %z altitude in meters
        
        GS=cell2mat(acdata(a,19))*1852/(time(a,2)-time(a,1)); %Ground speed of AC expressed im m/s
        flight_pos(n).GS=GS;
        
        track=atan2((y(2)-y(1)),(x(2)-x(1))); %calculate track in radians from x axis
        flight_pos(n).track=track;
        
        ROC=(z(2)-z(1))*100/((time(a,2)-time(a,1))/60); %calculate rate of climb or descent
        flight_pos(n).ROC=ROC;
        
        flight_pos(n).mode=cell2mat(acdata(a,9)); % 0=climb, 1=descent, 2=cruise
      n=n+1; 
     end
       
end
        
    










end



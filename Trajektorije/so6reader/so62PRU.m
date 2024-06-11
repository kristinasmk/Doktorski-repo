%so6 to look like TParchive
datet=[7 7 2019];
timet=10;

if datet(1)<10
    ddt=['0',num2str(datet(1))];
else
    ddt=num2str(datet(1));
end

if datet(2)<10
    mmt=['0',num2str(datet(2))];
else
    mmt=num2str(datet(2));
end

raw_so6=['2019',mmt,ddt,'_ActualTraffic.so6'];
desired_time=(timet-0.5)*3600;
endtime=desired_time+2*3600;
FlownArea=[36 10 54 24];
[flight_hist,flight_pos,flight] = so6reader_new (raw_so6,desired_time,endtime,FlownArea);

s=1;
for a=1:size(flight,2)
    acin=flight(a).time(:,1)>desired_time & flight(a).time(:,1)<endtime;
    
    if max(acin)>0
       TrafficArchive(s).name=flight(a).name;
       data=flight(a).data;
       n=1;
       for t=desired_time:endtime
           
           if t<flight(a).time(end,2)
           
           sopos=sum(t>flight(a).time(:,1));
               if sopos>0
               k=(t-flight(a).time(sopos,1))/(flight(a).time(sopos,2)-flight(a).time(sopos,1));

               d=data(sopos,:);

               nd(n,1)=(d{14}+k*(d{16}-d{14}))/60;
               nd(n,2)=(d{13}+k*(d{15}-d{13}))/60;
               nd(n,3)=(d{7}+k*(d{8}-d{7}))*100*0.3048;
               nd(n,4)=d{19}*1852/(flight(a).time(sopos,2)-flight(a).time(sopos,1));
               nd(n,5)=NavAngleToMathAngle(azimuth(d{13}/60,d{14}/60,d{15}/60,d{16}/60));
               
               nd(n,21)=t;
               n=n+1;
               end
           end
       end
       TrafficArchive(s).data=nd;
       clearvars nd
       s=s+1;
    end
end
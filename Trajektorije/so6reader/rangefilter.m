function [ACcut] = rangefilter (ACrawso6,lon1,lat1,lon2,lat2)
%this range filter will cut AC data outside defined range described with
%lon1,lat1, lon2 and lat2 points
%lat1 lon1 should be lower left coord while lon2 lat2 should be upper right
% example - lat1 35 lon1 10; lat2 55 lon2 25

py=[lat1 lat2 lat2 lat1 lat1]*60;
px=[lon1 lon1 lon2 lon2 lon1]*60;

AClat1S=cell2mat(ACrawso6(:,13))>=lat1*60;
AClat2S=cell2mat(ACrawso6(:,13))<=lat2*60;
AClatS=AClat1S&AClat2S;

AClon1S=cell2mat(ACrawso6(:,14))>=lon1*60;
AClon2S=cell2mat(ACrawso6(:,14))<=lon2*60;
AClonS=AClon1S&AClon2S;

ACpos=AClatS&AClonS;

ACcut=ACrawso6(ACpos,:);

last=find(ACpos,1,'last');

if last<length(ACpos)
    %creating end line if ac flew out airspace on time of crossing polygon 
    lastline(1,1)={'END_END'};
    lastline(1,2)=ACrawso6(last,2);
    lastline(1,3)=ACrawso6(last,3);
    lastline(1,4)=ACrawso6(last,4);

    x=[ACrawso6{last,14} ACrawso6{last,16}];
    y=[ACrawso6{last,13} ACrawso6{last,15}];

    [cxs,cys]=polyxpoly(x,y,px,py);

    koef=sqrt((x(2)-cxs)^2+(y(2)-cys)^2)/sqrt((x(2)-x(1))^2+(y(2)-y(1))^2);

    t1=ACrawso6{last,21};
    t2=ACrawso6{last,22};
    t=t1+koef*(t2-t1);
    lastline(1,5)={time_HHMMSS(t)};

    lastline(1,6)=ACrawso6(last,6);
    lastline(1,7)={ACrawso6{last,7}+koef*(ACrawso6{last+1,7}-ACrawso6{last,7})};
    lastline(1,8)=ACrawso6(last,8);
    lastline(1,9)=ACrawso6(last,9);
    lastline(1,10)=ACrawso6(last,10);
    lastline(1,11)=ACrawso6(last,11);
    lastline(1,12)=ACrawso6(last,12);
    lastline(1,13)=ACrawso6(last,13);
    lastline(1,14)=ACrawso6(last,14);
    lastline(1,15)={cys};
    lastline(1,16)={cxs};
    lastline(1,17)=ACrawso6(last,17);
    lastline(1,18)=ACrawso6(last,18);
    lastline(1,19)={sqrt((x(1)-cxs)^2+(y(1)-cys)^2)};    
    lastline(1,20)=ACrawso6(last,20);
    lastline(1,21)=ACrawso6(last,21);
    lastline(1,22)={t};
    lastline(1,23)=ACrawso6(last,23);
    
    ACcut=[ACcut;lastline];
end

end
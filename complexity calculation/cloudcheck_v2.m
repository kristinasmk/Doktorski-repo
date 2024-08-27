function ACcloud = cloudcheck_v2 (ACgrid,AllClouds,dims,ws,p)
%this function will check if an aircraft is located within a cloud in a
%given time period and it will give it a cloud indication for the cloud
%interaction calculation
%input ws is weather scenario
Cloudt=[AllClouds{:,6}]';
if ws>15
    ws=rem(ws,15);
    if ws==0
        ws=15;
    end
end

cws=[AllClouds{:,2}]'==ws;
Ct=zeros(size(ACgrid,1),1);
for i=1:size(ACgrid)
    t=ACgrid(i,10);
    [v,x]=min(abs(Cloudt-t));
    if x==1
        z=Cloudt==Cloudt(x);
        cm=AllClouds{z&cws,4}{1,p};
    elseif x>1 && v==0 
        z=Cloudt==Cloudt(x);
        cm=AllClouds{z&cws,4}{1,p};
    elseif x>1 && v>0
        if Cloudt(x)-t>0
        z=Cloudt==Cloudt(x-1);
        cm=AllClouds{z&cws,4}{1,p};
        elseif Cloudt(x)-t<0
        z=Cloudt==Cloudt(x);
        cm=AllClouds{z&cws,4}{1,p};
        end
    end
    %reshaping cell index from single line of cells to two-dimensional
    %grid, dimensions are swapped (should be [dims(1), dims(2)], but
    %PRU grid cells were created in lines, and not columns, so reshape and
    %ind2sub must be switched or rotated by 90° and flipped)
    %example for given case: flip(rot90(reshape(1:255,dims(2),dims(1))));
    [ACgridpos(2),ACgridpos(1)]=ind2sub([dims(2) dims(1)],ACgrid(i,11));
    [AC_Cloud_inter]=AC_in_cloudf ([ACgridpos(1),ACgridpos(2),ACgrid(i,12)],cm);
    Ct(i,1)=AC_Cloud_inter;
end
ACcloud=[ACgrid,Ct];
end
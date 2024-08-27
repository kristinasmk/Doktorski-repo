function [AC_Cloud_inter]=AC_in_cloudf (ACgridpos,CloudGrid)
%this function will chech AC cell and surrounding cells for potential cloud
%interactions
% ACgrid pos should be [r c h] row column height input
% CloudGrid should be 3D from cloud matrix from cloudGrid function

r=ACgridpos(1);
c=ACgridpos(2);
al=ACgridpos(3);
if al<1
    al=1;
end
Limits=size(CloudGrid);

if r==1
    if c==1
        if al==1
            block=CloudGrid(r:r+1,c:c+1,al:al+1);
        elseif al==Limits(3)
            block=CloudGrid(r:r+1,c:c+1,al-1:al);
        else  
            block=CloudGrid(r:r+1,c:c+1,al-1:al+1);
        end
        
    elseif c==Limits(2)
        if al==1
            block=CloudGrid(r:r+1,c-1:c,al:al+1);
        elseif al==Limits(3)
            block=CloudGrid(r:r+1,c-1:c,al-1:al);
        else
            block=CloudGrid(r:r+1,c-1:c,al-1:al+1);
        end
    else
        if al==1
            block=CloudGrid(r:r+1,c-1:c+1,al:al+1);
        elseif al==Limits(3)
            block=CloudGrid(r:r+1,c-1:c+1,al-1:al);
        else
            block=CloudGrid(r:r+1,c-1:c+1,al-1:al+1);
        end
    end
    
elseif r==Limits(1)
    
    if c==1
        if al==1
            block=CloudGrid(r-1:r,c:c+1,al:al+1);
        elseif al==Limits(3)
            block=CloudGrid(r-1:r,c:c+1,al-1:al);
        else
            block=CloudGrid(r-1:r,c:c+1,al-1:al+1);
        end
    elseif c==Limits(2)
        if al==1
            block=CloudGrid(r-1:r,c-1:c,al:al+1);
        elseif al==Limits(3)
            block=CloudGrid(r-1:r,c-1:c,al-1:al);
        else
            block=CloudGrid(r-1:r,c-1:c,al-1:al+1);
        end
    else
        if al==1
            block=CloudGrid(r-1:r,c-1:c+1,al:al+1);
        elseif al==Limits(3)
            block=CloudGrid(r-1:r,c-1:c+1,al-1:al);
        else
            block=CloudGrid(r-1:r,c-1:c+1,al-1:al+1);
        end
    end
else
    if c==1
        if al==1
            block=CloudGrid(r-1:r+1,c:c+1,al:al+1);
        elseif al==Limits(3)
            block=CloudGrid(r-1:r+1,c:c+1,al-1:al);
        else
            block=CloudGrid(r-1:r+1,c:c+1,al-1:al+1);
        end
    elseif c==Limits(2)
        if al==1
            block=CloudGrid(r-1:r+1,c-1:c,al:al+1);
        elseif al==Limits(3)
            block=CloudGrid(r-1:r+1,c-1:c,al-1:al);
        else
            block=CloudGrid(r-1:r+1,c-1:c,al-1:al+1);
        end
    else
        if al==1
            block=CloudGrid(r-1:r+1,c-1:c+1,al:al+1);
        elseif al==Limits(3)
            block=CloudGrid(r-1:r+1,c-1:c+1,al-1:al);
        else
            block=CloudGrid(r-1:r+1,c-1:c+1,al-1:al+1);
        end
    end 
end

if max(max(max(block)))>0
    AC_Cloud_inter=1;
else
    AC_Cloud_inter=0;
end

end
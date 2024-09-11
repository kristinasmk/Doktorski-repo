function [Cloudgrid,Cl] = CtG (clouddata,polygon,dims)
%cloud data to grid data for one cloud
%used grid [grids,polygon,dims] = gridcreate (10,45,18,50,20,100,450);
%cloud data is one weather scenario from AllClouds data i.e. AllClouds{1,3} 
Cloudgrid=cell(1,4);
Cl=zeros(dims(1)*dims(2),36,4);
for p=1:4
Clgrid=zeros(dims(1),dims(2),36); %36 is number of levels from 100 to 450 according to PRU 

    for i=1:size(clouddata,1)
    CTH=round(clouddata{i,1}/0.3048/1000)*10;
    coords=clouddata{i,2};
    altpos=(CTH-100)/10+1;  %calculat1e vertical position of CTH in PRU grid


    n=2;
    %this loop will add points to ensure that there is at least one
    %point per PRU cell distance to ensure there is no gaps when
    %filling Cloud grid for PRU
        while n<=size(coords,1)
            p1=[coords(n-1,1),coords(n-1,2)];
            p2=[coords(n,1),coords(n,2)];
            d=distance(p1(1),p1(2),p2(1),p2(2));
            if deg2nm(d)>20 %max distance between points 20NM (dimension of a cell)
               MidPoint = MidPointf (p1, p2);
               coords=[coords(1:n-1,:);MidPoint;coords(n:end,:)];
            end
            n=n+1;
        end



        cloudG=zeros(dims(1)*dims(2),1);
        [in, index] = inpolygons(coords(:,1),coords(:,2),polygon.xaxis(p,:),polygon.yaxis(p,:));

        index=unique([index{in}]');
        cloudG(index)=1;

        if max(cloudG)>0
        %since cloudG is single line arrray it should be reshaped
        %to fit shape of PRU grid
        cloudM=flip(rot90(reshape(cloudG,dims(2),dims(1))));

        %filling holes since up to now only borders were marked
        cloudM = fullmask (cloudM);

        %logging cloud in cloud cell before starting on next cloud
            for c=1:altpos
                 Clgrid(:,:,c)=Clgrid(:,:,c)+cloudM;   
            end
        end
    end
%logging cloud data
Cloudgrid(p)={logical(Clgrid)};
Cl(:,:,p)=logical(reshape(Clgrid,[dims(1)*dims(2),36]));
end


end
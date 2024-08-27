function [AirBL,ABList] =airblocks (Airblockx,abl)

addpath(genpath(fileparts(pwd)))

%this function extracts airblock coordinates and put them in AirBL struct

%this list function will create new list with redone names starting with AB
%because previous names started with number

AirblockList=Airblockx(abl);
ABList = lista (AirblockList, 'AB');

%creating empty structur
AirBL(numel(abl)-1)=struct();

for ab=2:numel(abl)
                   
                   
                    airblock=Airblockx(abl(ab-1)+1:abl(ab)-1,2:3);
           
                   %extracting charrs for each coordinates
                    airblockcharN=char(airblock(:,1));
                    airblockcharE=char(airblock(:,2));

                    degN=str2num(airblockcharN(:,2:3));
                    minN=str2num(airblockcharN(:,4:5));
                    secN=str2num(airblockcharN(:,6:7));

                    degE=str2num(airblockcharE(:,2:4));
                    minE=str2num(airblockcharE(:,5:6));
                    secE=str2num(airblockcharE(:,7:8));

                    koordN=degN+minN/60+secN/3600;
                    koordE=degE+minE/60+secE/3600;

                    airblock=[koordN, koordE];
                    
                    AirBL(ab-1).name=ABList(ab-1);
                    AirBL(ab-1).coords=airblock;
                    
                    %this function will add extra points to airbl list to
                    %smoothen transition between points (it is done in 3
                    %loops so number of points is increased by 2^4)
                    % adding so many points is required if grid raster is
                    % reduced down to 5 NM
                    n=2;
                    coords=airblock;
                    %this loop will add points to ensure that there is at least one
                    %point per PRU cell distance to ensure there is no gaps when
                    %filling Cloud grid for PRU
                        while n<=size(coords,1)
                            p1=[coords(n-1,1),coords(n-1,2)];
                            p2=[coords(n,1),coords(n,2)];
                            d=distance(p1(1),p1(2),p2(1),p2(2));
                            if deg2nm(d)>5 %max distance between points 10NM
                               MidPoint = MidPointf (p1, p2);
                               coords=[coords(1:n-1,:);MidPoint;coords(n:end,:)];
                            end
                            n=n+1;
                        end
                   AirBL(ab-1).ncoords=coords;
                   
end

ABList=ABList(1:end-1,:);
end
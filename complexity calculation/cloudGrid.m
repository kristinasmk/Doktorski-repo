function [cloudGrid3D] = cloudGrid (Clouddata,polygon,dims,FL1,FL2,startT,endT,raster)
% this function reads all clouds and fill them in PRU grid as mask for
% calculation AC-cloud interactions

altrange=size(FL1:10:FL2,2);
cloudGrid3D=Clouddata(:,2);

%ovo se možda makne ispred same funkcije da ne ostanu prazna mjesta
[~,kreni]=min(abs([Clouddata{:,2}]-startT));
[~,stani]=min(abs([Clouddata{:,2}]-endT));


%this loop will open every cloud data image in 5 minute time interval
    for c=kreni:stani
        
        Clouds=Clouddata{c,3};
        
        %this part will filter out all clouds with thickness of just 1 FL
        Alt=[Clouds{:,1}];
        Alt=(reshape(Alt,2,size(Alt,2)/2))';
        Altd=(Alt(:,2)-Alt(:,1))>0;
        Clouds=Clouds(Altd,:);
              
        %create empty cell to full with cloud masks
        CloudsM=cell(size(Clouds,1),4);
        
        %this loop will open every cloud
        for i=1:size(Clouds,1)
            n=2;
            Cloud=Clouds{i,2};
            %this loop will add points to ensure that there is at least one
            %point per PRU cell distance to ensure there is no gaps when
            %filling Cloud grid for PRU
                while n<=size(Cloud,1)
                    p1=[Cloud(n-1,1),Cloud(n-1,2)];
                    p2=[Cloud(n,1),Cloud(n,2)];
                    d=distance(p1(1),p1(2),p2(1),p2(2));
                    if deg2nm(d)>raster %max distance between points 10NM
                       MidPoint = MidPointf (p1, p2);
                       Cloud=[Cloud(1:n-1,:);MidPoint;Cloud(n:end,:)];
                    end
                    n=n+1;
                end
            %when points are added PRUgrid will be filled with points
            for p=1:4
                cloudG=zeros(dims(1)*dims(2),1);
                [in, index] = inpolygons(Cloud(:,2),Cloud(:,1),polygon.xaxis(p,:),polygon.yaxis(p,:));
             
                index=unique([index{in}]');
                cloudG(index)=1;
                %since cloudG is single line arrray it should be reshaped
                %to fit shape of PRU grid
                cloudM=flip(rot90(reshape(cloudG,dims(2),dims(1))));
                
                %filling holes since up to now only borders were marked
                cloudM = fullmask (cloudM);
                
                %logging cloud in cloud cell before starting on next cloud
                CloudsM(i,p)={cloudM};
             end
        end
        
        %crate 3D PRU cloud mask
        CloudPRU=zeros(dims(1),dims(2),altrange,4);
        for s=1:4
            for m = 1:size(CloudsM,1)
                AltC=Clouds{m,1};
                CloudM=CloudsM{m,s};
                [~,indexb]=min(abs((FL1/10:FL2/10)-AltC(1)));
                [~,indext]=min(abs((FL1/10:FL2/10)-AltC(2)));
                
                CloudPRU(:,:,indexb:indext,s)=CloudPRU(:,:,indexb:indext,s)+CloudM;
                
            end
        end
        CloudPRU=CloudPRU>0;  
        cloudGrid3D(c,2)={CloudPRU};
    end
end
        
addpath(genpath(pwd));  
% Vizualisation of cloudddata
% figure
% hold on
% 
% for i=1:size(TrafficArchive,2)
%     scatter(TrafficArchive(i).data(:,1),TrafficArchive(i).data(:,2),'.')
% end
% 
% AstarGrid.lon1=10;
% AstarGrid.lat1=35;
% AstarGrid.lon2=25;
% AstarGrid.lat2=55;
% 
% for c=3%size(Clouddata,1)
% [CloudsAll,~,~,~] = cloudMerge (Clouddata{c,3},AstarGrid);
% plot(CloudsAll(:,2),CloudsAll(:,1))
% end
warning('off','MATLAB:polyshape:repairedBySimplify');



 load 'europeshapeloaded.mat'
 load Clouddata2106.mat
% load Traffarch0707.mat


AstarGrid.lon1=10;
AstarGrid.lat1=35;
AstarGrid.lon2=25;
AstarGrid.lat2=55;

%%
iter=floor(size(Clouddata,1)/4);
index=1:5;
s=1;
i=0:4:size(Clouddata,1);
in=zeros(iter,5);
while s<iter+1
   in(s,:)=index+i(s);
   s=s+1;
end

timeline=Clouddata{1,2}:900:Clouddata{1,2}+in(end,4)*900;

for n=1:size(in,1)
figure
hold on
xlim([10 25])
ylim([35 55])
set(gcf, 'Position',  [100, 100, 1000, 800])

plot(a(6).X,a(6).Y);
pts=timeline(in(n,1));
pte=timeline(in(n,5));

cl=[Clouddata{:,2}]';
clouds=cl>=pts & cl<=pte;
clouds=Clouddata(clouds,:);

for c=1:size(clouds,1)

[CloudsAll,~,C3D,~] = cloudMerge (clouds{c,3},AstarGrid);
    for d=1:size(C3D,1)
        if ~isempty(C3D{d})
            n=zeros(size(C3D{d},1),1);
            n=n+d;
            plot3(C3D{d}(:,2),C3D{d}(:,1),n*304.8)
        end
    end
end

end

% [ACdata] = plotAChist (ACname,flight);
% p=plot3(ACdata(:,2),ACdata(:,1),ACdata(:,3));
% p.LineWidth=3;


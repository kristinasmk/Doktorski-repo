%cloud mask script 
%th0is script will load all clouds into PRU grid to be used for cloud
%indicator calculation

clear
addpath(genpath(pwd))

%create PRU grid
[grids,polygon,dims] = gridcreate (10,45,18,50,20,100,450);

%load weather data
load Cloudmat_NAVSIM

for i=1:size(AllClouds,1)
    %create cloud mask
    [cmask,cm]=CtG(AllClouds{i,3},polygon,dims);
    %log cloud mask
    AllClouds(i,4)={cmask};
    AllClouds(i,5)={cm};
    
end
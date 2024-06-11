%get image list
% IMlist=dir('*).tif');
clear

[A,R]=geotiffread('test_cro2.tif');


%get RGB legend
load RGBalt

%start with first image
% Clouds=imread('test.tif');

%create rgb bands
% CLoudsRGB=Clouds(:,:,1:3);
Clouds=A;

%Split RGB bands
CloudR=Clouds(:,:,1);
CloudG=Clouds(:,:,2);
CloudB=Clouds(:,:,3);

%create empty variables
Binary=zeros(size(CloudR,1),size(CloudR,2),48);

CTca=zeros(size(CloudR,1),size(CloudR,2),48);
Binarys=Binary;

% for each altitude level accept highest (white)
for i=2:48
    
    NewIM=zeros(size(Clouds,1),size(Clouds,2));
    NewIMr=uint8(NewIM);
    NewIMg=uint8(NewIM);
    NewIMb=uint8(NewIM);
    
    CR=CloudR==RGBalt(i,1);
    CG=CloudG==RGBalt(i,2);
    CB=CloudB==RGBalt(i,3);
    
    
    CT=CR&CG&CB; % per each RGB altitue level
    
    %filter each RGB band
    NewIMr(CT)=CloudR(CT);
    NewIMg(CT)=CloudG(CT);
    NewIMb(CT)=CloudB(CT);
    
    aimg(:,:,1)=NewIMr;
    aimg(:,:,2)=NewIMg;
    aimg(:,:,3)=NewIMb;
    
    % log in binary image 0 is no cloud 1 is cloud in (x,y,h)
    Binary(:,:,i)=CT;
    NewIMt(i).altimg=aimg;
    
    %merginig successive levels from highest to lowest 
    if i==1
        Binarys(:,:,i)=CT;
    else
        Binarys(:,:,i)=Binarys(:,:,i-1)+CT;
    end

%    
end

%sum all cloud levels
Bins=permute(sum(permute(Binarys,[3,1,2])),[2 3 1]);
Bins=flip(Bins,1);


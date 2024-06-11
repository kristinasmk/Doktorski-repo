%get image list
% IMlist=dir('*).tif');
clear

[A,R]=geotiffread('test_cro.tif');


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

Binary=zeros(size(CloudR,1),size(CloudR,2),48);

CTca=zeros(size(CloudR,1),size(CloudR,2),48);
Binarys=Binary;

for i=2:48
    
    NewIM=zeros(size(Clouds,1),size(Clouds,2));
    NewIMr=uint8(NewIM);
    NewIMg=uint8(NewIM);
    NewIMb=uint8(NewIM);
    
    CR=CloudR==RGBalt(i,1);
    CG=CloudG==RGBalt(i,2);
    CB=CloudB==RGBalt(i,3);
    
    CT=CR&CG&CB; % ovo nije dobro! 0 je isto dio RGB-a
    
    NewIMr(CT)=CloudR(CT);
    NewIMg(CT)=CloudG(CT);
    NewIMb(CT)=CloudB(CT);
    
    aimg(:,:,1)=NewIMr;
    aimg(:,:,2)=NewIMg;
    aimg(:,:,3)=NewIMb;
    
    Binary(:,:,i)=CT;
    NewIMt(i).altimg=aimg;
    
    if i==1
        Binarys(:,:,i)=CT;
    else
        Binarys(:,:,i)=Binarys(:,:,i-1)+CT;
    end
    
    
   % cleaning and imclose 
   se=strel('disk',2);
   
   CTcl=imclose(CT,se);
   CTca(:,:,i)=CTcl;
   
   
    NewIMrc=uint8(NewIM);
    NewIMgc=uint8(NewIM);
    NewIMbc=uint8(NewIM);
   
    NewIMrc(CTcl)=RGBalt(i,1);
    NewIMgc(CTcl)=RGBalt(i,2);
    NewIMbc(CTcl)=RGBalt(i,3);
    
    NewIMc(i).altimg=aimg;
   
end

Bins=permute(sum(permute(Binarys,[3,1,2])),[2 3 1]);
Bins=flip(Bins,2);
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
NewIMt=zeros(size(CloudR,1),size(CloudR,2),3,48);

CTca=zeros(size(CloudR,1),size(CloudR,2),48);
NewIMc=zeros(size(CloudR,1),size(CloudR,2),3,48);

for i=1:48
    
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
    
    Binary(:,:,i)=CT;
    NewIMt(:,:,1,i)=NewIMr;
    NewIMt(:,:,2,i)=NewIMg;
    NewIMt(:,:,3,i)=NewIMb;
    
   % cleaning and imclose 
   se=strel('disk',1);
   
   CTcl=imopen(CT,se);
   CTca(:,:,i)=CTcl;
   
   
    NewIMrc=uint8(NewIM);
    NewIMgc=uint8(NewIM);
    NewIMbc=uint8(NewIM);
   
    NewIMrc(CTcl)=RGBalt(i,1);
    NewIMgc(CTcl)=RGBalt(i,2);
    NewIMbc(CTcl)=RGBalt(i,3);
    
    NewIMc(:,:,1,i)=NewIMrc;
    NewIMc(:,:,2,i)=NewIMgc;
    NewIMc(:,:,3,i)=NewIMbc;
   
end

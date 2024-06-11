function [Bins,Binary,NewIMt] = geotifproc (geotifA,RGBalt)
%tihs function will read geotif and process its image part to to prepare it
%for CB detection
%input to this function is:
% goetifA - A fom geotiffread function
% RGBalt - RGB legend of altitude codes from 320m to 160000m with 320m step
%outputs from function:
% Bins - consecutive sum of cloud layers from top to bottom altitude
% Binary - log of every altitude layer from top to bottom
% NewIMt - RGB log of every altitde layer from top to bottow

% [A,~]=geotiffread(goetifname);



%start with first image
% Clouds=imread('test.tif');

%create rgb bands
% CLoudsRGB=Clouds(:,:,1:3);
Clouds=geotifA;

%Split RGB bands
CloudR=Clouds(:,:,1);
CloudG=Clouds(:,:,2);
CloudB=Clouds(:,:,3);

Binary=zeros(size(CloudR,1),size(CloudR,2),48);

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
    
end

Bins=permute(sum(permute(Binarys,[3,1,2])),[2 3 1]);
Bins=flip(Bins);
end

load RGBalt
map_name = 'testtiff.tif';
filename = 'test_cro2.tif';

%cut global map to area of croatia
[subImage,subR] = tifcutf (map_name, filename);

%preprocess image for CB detection
[Bins,Binary,NewIMt] = geotifproc (subImage,RGBalt);

%Bins=flip(Bins);
%Detect potential cb positions
CBpos = CBdetect (Bins);

%round areas and find coordinates of potential CBs.
[CBindex,CBcoord] = CBarea (CBpos,subImage,filename);


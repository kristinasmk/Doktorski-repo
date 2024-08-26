%configuration reader
clear
addpath(genpath(pwd))
%import sector parts from json for building used sectors 
SectorParts=fileread('2018-05-24_ACC_SECTOR_PARTS.json');
SectorDataParts=jsondecode(SectorParts);
SectorsP=cell(size(SectorDataParts.features,1),4);
% for each part extract name, vertical and horizontal boundaries
for i=1:size(SectorDataParts.features,1)
    SectorsP(i,1)={SectorDataParts.features(i).properties.DESIGNATOR};
    SectorsP(i,2)={SectorDataParts.features(i).properties.UPPER_LIMIT_VALUE};
    SectorsP(i,3)={SectorDataParts.features(i).properties.LOWER_LIMIT_VALUE};
    coords=permute(SectorDataParts.features(i).geometry.coordinates,[2,3,1]);
    SectorsP(i,4)={coords};
end

%create PRU grid
[grids,polygon,dimensions] = gridcreate (10,45,18,50,20,100,450);

%create sector parts mask in PRU
[SectPart] = SectorMask (SectorsP, polygon, dimensions,100,450);

SectorsP(contains(SectorsP(:,1),'LJMURA1'),1)={'LO_S1'};
SectorsP(contains(SectorsP(:,1),'LJMURA2'),1)={'LO_S2'};
SectorsP(contains(SectorsP(:,1),'LJMURA3'),1)={'LO_S3'};
SectorsP(contains(SectorsP(:,1),'LJMURA4'),1)={'LO_S4'};
SectorsP(contains(SectorsP(:,1),'LJMURA5'),1)={'LO_S5'};

%combine sector parts into Sectors
Sectors=unique(SectorsP(:,1));

%create empty cell for all combined sector parts
Asectors=cell(size(Sectors,1),4);

%for list of unique sectors components
for i=1:size(Sectors,1)
    
    Dub=strcmp(Sectors(i),SectorsP(:,1));
    
    if sum(Dub)>1
       Comb=SectPart(Dub,:);
       
       for n=1:4
           A=zeros(size(Comb{1,1}));
           for ii=1:size(Comb,1)
               A=A+Comb{ii,n};
           end
            Asectors(i,n)={double(A>0)};
       end

    else
        Asectors(i,:)=SectPart(Dub,:);
    end
end

%building merged sectors
load TrafVol

MerSect=cell(size(TV2,1),3);

%filtering sector data
for i=1:size(TV2,1)
    n=char(TV2{i,9});
    n=str2num(n(2:end-1));
    MerSect(i,2)={n};    
    
    n=char(TV2{i,7});
    MerSect(i,1)={n};
    L1={};
    %mach naming of sectors with json file
    if numel(n)<2
        L=lista(num2str(MerSect{i,2}'),['LO_',n]);
        MerSect(i,3)={L};
        
    else
        for x=1:numel(n)
            L=lista(num2str(MerSect{i,2}'),['LO_',n(x)]);
            L1=[L1;L];
        end
        MerSect(i,3)={L1};
    end
    
end
n=char([TV2{:,1}]');
n=cellstr(n(:,5:end));

MerSect=[n,MerSect];


%----------------------------
% reading configurations from excel

%load sector configuratios for reaserched days
load SectorConfigs
sc=SectConf20180613;

%extract logged sectors from table
for i=2:size(sc,1)
   slist=sc(i,4:end);
   slist=slist(~cellfun(@isempty,[slist{:}]));
   sconfs(i-1,1)={slist};
end

%combining elementary sectors to collapsed sectors
for i=1:size(sconfs,1)
    L=sconfs{i,1};
    Cm=cell(size(L));
    for x=1:size(L,2)
        if contains(L{x}," ")
            y=char(L{x});
            y=y(1:end-1);
            L(x)={y};
        end
        z=MerSect{strcmp(MerSect(:,1),L{x}),4};
        M=cell(1,4);
        for n=1:4
            mask=zeros(size(Asectors{1,1}));
            for ii=1:size(z,1)
               mask=mask+Asectors{strcmp(Sectors,z(ii)),n};
            end
            mask=mask>0;
            M(n)={mask};
        end
        Cm(x)={M};
    end
    sconfs(i,2)={Cm};
end
sconfs=[num2cell(round([SectConf20180613{2:end,1}]'*24*60*60,-2)),...
    num2cell(round([SectConf20180613{2:end,2}]'*24*60*60,-2)),sconfs];













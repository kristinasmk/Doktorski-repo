function [Sector] = SectorMask (Sectdata, polygon, dims,FL1,FL2)
%----------------
% this function will create Sector mask based on PRU grid
% inputs to this function are:
%   Sectdata - obtained extracted from json file
%   grid - 2D grid vertexes data obtaine from gridf function
%   polygon - array of points created via gridf function as inputs for
%   inpolygons function
%   dims - dimensions of grid as in number of grid cells in two dimensions
%-----------------

%this loop will test each coordinate from Sector parts polygon and put it in mask
%creating altitude scale for vertial positioning of sector
altscale=FL1:10:FL2;
%testing in which grid cell is coordinates
for a=1:size(Sectdata,1)
    for p=1:4
        %locate positions of sector parts borders within PRU grid
        abmask=zeros(dims(1)*dims(2),1);
        [in,idx]=inpolygons(Sectdata{a,4}(:,1),Sectdata{a,4}(:,2),polygon.xaxis(p,:),polygon.yaxis(p,:));
        Uniq=unique([idx{in}]');
        abmask(Uniq)=1;
        abmask=flip(rot90(reshape(abmask,dims(2),dims(1))));
        
        %since sector border coordinates are just vortexes of polygons mask some areas are
        %opened and should be filled with ones 
        abmask=fullmask(abmask);
        
        %log 2D profile of sector
        AirBLM(a,p)={abmask};

        %create sector in space
        %create empty variable
        sectmask=zeros(dims(1),dims(2),size(altscale,2));
        %locate vertical span of sector
        abalt=Sectdata{a,3}<altscale & Sectdata{a,2}>altscale;
        %fill each FL of vertical span with 2D profile of sector
        sectmask(:,:,abalt)=sectmask(:,:,abalt)+abmask;
        %log 3D profile of sector
        Sector(a,p)={sectmask};
    end
end









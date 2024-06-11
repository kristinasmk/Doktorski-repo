function [CBindex,CBcoord] = CBarea (CBpos,A,geotif) 
%Ova funkcija zaokru�uje prostore oko potencijalnih CBa, prikazuje ih i 
%indeksira te izdvojene prostore preko geotiff podataka smje�ta u prostor.
%inputs: 
% CBpos - matrica izra�unatih lokalnih maksimuma
% A,R - geotiff podaci iz geotiffread
%output:
%CBindex - poligon pixela koji zaokru�uju prostore CB-a na slici A
%CBcoords - kooridnate to�aka it CB index

PotentialCB1=CBpos;


%ovaj dio je bolji za okviriti CB potencijalni prostor (onako �uto
%ozna�eni)
%ovo bi se dalje moglo izrezati iz ukupne slike i onda dalje izdvajati
%probijanja gdje bi se ozna�io crveni sloj

P5=imclose(PotentialCB1,strel('disk',5));
P6=imopen(P5,strel('disk',2));
P7=bwboundaries(P6);
CBindex=P7;

imshow(A)
hold on;
% za zaokru�ivanje svakog poligona na karti
for k=1:size(P7)
   b = P7{k};
   plot(b(:,2),b(:,1),'b','LineWidth',3);
end

% ovaj dio ovjde vadi koordinate to�aka poligona P7 iz geotiff podataka
% Get image info: 
R = geotiffinfo(geotif); 

% Get x,y locations of pixels: 
[x,y] = pixcenters(R); 
% Convert x,y arrays to grid: 
[X,Y] = meshgrid(x,y);
% Remove trailing nan from shapefile
for i=1:size(P7,1)
    rx = P7{i,1}(:,1);
    ry = P7{i,1}(:,2);
    for ii=1:size(rx,1)
        CBa(ii,1)=X(rx(ii),ry(ii));
        CBa(ii,2)=Y(rx(ii),ry(ii));
    end
    CBs{i,1}=CBa;
end

CBcoord=CBs;
end


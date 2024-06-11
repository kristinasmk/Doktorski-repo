

P2=imclose(PotentialCB1,strel('disk',2));
P4=bwboundaries(P2);

imshow(A)
hold on;
% za zaokruživanje svakog poligona na karti
for k=1:17
   b = P4{k};
   plot(b(:,2),b(:,1),'b','LineWidth',3);
end

%ovaj dio je bolji za okviriti CB potencijalni prostor (onako žuto
%oznaèeni)
%ovo bi se dalje moglo izrezati iz ukupne slike i onda dalje izdvajati
%probijanja gdje bi se oznaèio crveni sloj

P5=imclose(PotentialCB1,strel('disk',5));
P6=imopen(P5,strel('disk',2));
P7=bwboundaries(P6);
imshow(A)
hold on;
% za zaokruživanje svakog poligona na karti
for k=1:size(P7)
   b = P7{k};
   plot(b(:,2),b(:,1),'b','LineWidth',3);
end

% ovaj dio ovjde vadi koordinate toèaka poligona P7 iz geotiff podataka
% Get image info: 
R = geotiffinfo('test_cro.tif'); 
% Get x,y locations of pixels: 
[x,y] = pixcenters(R); 
% Convert x,y arrays to grid: 
[X,Y] = meshgrid(x,y);
roi = shaperead('shapefile_example.shp');
% Remove trailing nan from shapefile
for i=1:17
    rx = P4{i,1}(:,1);
    ry = P4{i,1}(:,2);
    for ii=1:size(rx,1)
        CBa(ii,1)=X(rx(ii),ry(ii));
        CBa(ii,2)=Y(rx(ii),ry(ii));
    end
    CBs{i,1}=CBa;
end
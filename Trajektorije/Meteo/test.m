[A,R]=geotiffread('testGeoTif.tif');
%�ita tif i i pohranjuje, A su podaci karte, R su gereference
% A ima 4 podatka u tre�oj dimenziji (RGB), a za geoshow funkciju ide samo
% 3, 4-ti broj su svu oblaci zajedno u bijeloj boji a ono �to nema oblaka
% crno
geoshow(A(:,:,1:3),R) 
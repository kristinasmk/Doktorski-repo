function plotbin = plotbinm (binmatr)
%this function plot 3D binary matrix
[x, y, z] = ind2sub(size(binmatr), find(binmatr));
plotbin=plot3(x, y, z, 'k.');

end
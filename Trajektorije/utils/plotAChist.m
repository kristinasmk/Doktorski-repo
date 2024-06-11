function [ACdata] = plotAChist (AC,hist)
%plot from history


A=struct2cell(hist);
A=permute(A,[3 1 2]);

ACd=strcmp(A(:,1),AC)==1;

data=A{ACd,2};

y=([data{:,13}]/60)';
y=[y;data{size(data,1),15}/60];

x=([data{:,14}]/60)';
x=[x;data{size(data,1),16}/60];

z=([data{:,7}]*100*0.3048)';
z=[z;data{size(data,1),8}*100*0.3048];

ACdata=[y,x,z];

%plot3(x,y,z)

end

function [SectConfig,nConf] = confselect (dateo, timeo, OpSch, OpSchn,Configurations)
%this function will select opening configuration on desired date of opening
%and time of opening from opening Scheme
%inputs:
%dateo - [dd, mm, yyyy]
%timeo - [hh]
%OpSch and OpSchn - data from nest

D=OpSchn(:,1)==dateo(1) & OpSchn(:,2)==dateo(2) & OpSchn(:,3)==dateo(3);
Ds=OpSch(D,:);
D=OpSchn(D,:);

Dt=sum(D(:,4)<=timeo);

SectConfig=Ds(Dt,2);
a=(extractfield(Configurations,'name'))';

for i=1:size(a,1)
    an(i)=a{i};
end

nConf=find(strcmp(an,SectConfig));
end
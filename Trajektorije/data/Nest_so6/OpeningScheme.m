
OpSch=cell(1,3);
OpSchn=[1 2 3 4 5 6 7];
Schemems=dir('*.cos');
for i=1:size(Schemems,1)
    fid = fopen(Schemems(i).name);
    data = textscan(fid,'%d %d %d %s %d %d %d %d %s %s','delimiter',{'/',':',';'});
    
    dataex2=[data{1},data{2},data{3},data{5},data{6},data{7},data{8}];
    dataex=[data{4},data{9},data{10}];
    OpSch=[OpSch;dataex];
    OpSchn=[OpSchn;dataex2];
    
end

OpSch=OpSch(2:end,:);
OpSchn=OpSchn(2:end,:);

Cro=strcmp(OpSch(:,1),'LDZOCTA');
OpSch=OpSch(Cro,:);
OpSchn=OpSchn(Cro,:);
OpSch(:,2)=strrep(OpSch(:,2),'.','-');
OpSch(:,2)=strrep(OpSch(:,2),'-N','_N');



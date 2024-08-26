Workbook='20180602_12_13_Sektoröffnungen ACC.xlsx';
sheetName=sheetnames(Workbook);
for i=1:numel(sheetName)
Confs =DailySectorsImport(Workbook,sheetName(i));
b=cellstr(reshape([Confs{:}],size(Confs)));
n=sum(contains(b(:,1),'0'));
b=b(1:n+1,:);
C(i)={b};

end
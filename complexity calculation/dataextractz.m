%data export script
%this cript will export data logged in complexity results
clear
load ComplexityKIKAposektorima.mat
% CplxNO from 1:3 is configuration with 10 sectors  (10A1)  B15, W45, W3, W12, S35, S12, E45, E13, N35, N12
% CplxCO from 1:5 is configuration with 10 sectors  (10A1)  B15, W45, W3, W12, S35, S12, E45, E13, N35, N12
% CplxCO from 6:12 is configuration with 9 sectors  (9A1)   B15,    W35,  W12, S35, S12, E45, E13, N35, N12
% CplxCO from 13:15 is configuration with 8 sectors (8S)    B15,    W35,  W12, S35, S12,   E15,    N35, N12
% CplxCO from 16:20 is configuration with 7 sectors (7WB1)  WB35, WB12,        S35, S12,   E15,    N35, N12	
% CplxCO from 21 is configuration with 6 sectors    (6WB1)  WB35, WB12,         S15,       E15,    N35, N12
	
z=cell(400,1);
Config={'B15', 'W45', 'W3', 'W12', 'S35', 'S12', 'E45', 'E13', 'N35', 'N12'};

Conf12001240={'sector','t+00','t+20','t+40'};
for n=1:10
    Cp=Cplx(:,1:3,n);
    A=[];
     for i=1:15
       A=[A;cellfun(@(v)v(n),Cp(:,:,i))];
     end
%    z = cell(size(A,1),1);
   z(:)=Config(n);
   A=[z,num2cell(A)];
   Conf12001240=[Conf12001240;A];
end
writecell(Conf12001240,'Conf12001240.csv')


load ComplexityKIKACOLOVV13_20.mat
z=cell(1000,1);

Config={'B15', 'W45', 'W3', 'W12', 'S35', 'S12', 'E45', 'E13', 'N35', 'N12'};
Conf13001420={'sector','t+60','t+80','t+100','t+120','t+140'};
for n=1:10
    Cp=Cplx(:,1:5,:);
    B=[];
    for i=1:20
    B=[B;cellfun(@(v)v(n),Cp(:,:,i))];
    end
   z(:)=Config(n);
   B=[z,num2cell(B)];
   Conf13001420=[Conf13001420;B];
    
end
writecell(Conf13001420,'Conf13001420.csv')


Config={'B15', 'W35', 'W12', 'S35', 'S12', 'E45', 'E13', 'N35', 'N12'};
Conf14401640={'sector','t+160','t+180','t+200','t+220','t+240','t+260','t+280'};
for n=1:9
    Cp=Cplx(:,6:12,:);
    C=[];
    for i=1:20
    C=[C;cellfun(@(v)v(n),Cp(:,:,i))];
    end
   z(:)=Config(n);
   C=[z,num2cell(C)];
   Conf14401640=[Conf14401640;C];
end
writecell(Conf14401640,'Conf14401640.csv')

Config={'B15', 'W35', 'W12', 'S35', 'S12', 'E15', 'N35', 'N12'};
Conf17001740={'sector','t+300','t+320','t+340'};
for n=1:8
    Cp=Cplx(:,13:15,:);
    C=[];
    for i=1:20
    C=[C;cellfun(@(v)v(n),Cp(:,:,i))];
    end
   z(:)=Config(n);
   C=[z,num2cell(C)];
   Conf17001740=[Conf17001740;C];
end
writecell(Conf17001740,'Conf17001740.csv')

Config={'WB35', 'WB12', 'S35', 'S12', 'E15', 'N35', 'N12'};
Conf18001920={'sector','t+360','t+380','t+400','t+420','t+440'};
for n=1:7
    Cp=Cplx(:,16:20,:);
    C=[];
    for i=1:20
    C=[C;cellfun(@(v)v(n),Cp(:,:,i))];
    end
   z(:)=Config(n);
   C=[z,num2cell(C)];
   Conf18001920=[Conf18001920;C];
end
writecell(Conf18001920,'Conf18001920.csv')

Config={'WB35', 'WB12', 'S15', 'E15', 'N35', 'N12'};
Conf19401940={'sector','t+460'};
for n=1:6
    Cp=Cplx(:,21,:);
    C=[];
    for i=1:20
    C=[C;cellfun(@(v)v(n),Cp(:,:,i))];
    end
   z(:)=Config(n);
   C=[z,num2cell(C)];
   Conf19401940=[Conf19401940;C];
end
writecell(Conf19401940,'Conf19401940.csv')

% load('LOVVcomplexity.mat')
% Cp=Cplx(:,1:12,:);
% D=[];
% for i=1:15
% D=[D;cellfun(@(v)v(1),Cp(:,:,i))];
% end
% z(:)={'LOVV'};
% D=[z,num2cell(D)];
% name={'sector','t+00','t+05','t+10','t+15','t+20','t+25','t+30','t+35','t+40','t+45','t+50','t+55'};
% writecell([name;D],'Conf12001255.csv')
% 
% 
% figure
% hold on
% M=mean(cell2mat(D(:,2:13)));
% sd=std(cell2mat(D(:,2:13)));
% Nmi=M-sd;
% Nma=M+sd;
% plot(M,'b')

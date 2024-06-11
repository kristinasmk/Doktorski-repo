function [apfdata] = readAPFfile(apffilename)
%Parses BADA OPF file and returns struct with data.
%
%Input:
%       apsfilename - filename of the APF file to be parsed
%
%Output:
%       apsdata - struct with all data read from the APF file


fid = fopen(apffilename);

data = textscan(fid,'%s','delimiter',{'\n'});

a = char(data{1,1}(13));
apfdata.LO=str2mat(a(10:15));
apfdata.HI=str2num(a(69:74));

b = textscan(char(data{1,1}(21)),...
    '%*27c %11f %11f %11f %11f %11f %11f %11f %11f %11f %11f %11f %11f');
apfdata.V_cl1.LO=b{1};
apfdata.V_cl2.LO=b{2};
apfdata.M_cl.LO=b{3};
apfdata.V_cr1.LO=b{4};
apfdata.V_cr2.LO=b{5};
apfdata.M_cr.LO=b{6};
apfdata.M_des.LO=b{7};
apfdata.V_des2.LO=b{8};
apfdata.V_des1.LO=b{9};

c = textscan(char(data{1,1}(22)),...
    '%*27c %11f %11f %11f %11f %11f %11f %11f %11f %11f %11f %11f %11f');
apfdata.V_cl1.AV=c{1};
apfdata.V_cl2.AV=c{2};
apfdata.M_cl.AV=c{3};
apfdata.V_cr1.AV=c{4};
apfdata.V_cr2.AV=c{5};
apfdata.M_cr.AV=c{6};
apfdata.M_des.AV=c{7};
apfdata.V_des2.AV=c{8};
apfdata.V_des1.AV=c{9};

d = textscan(char(data{1,1}(23)),...
    '%*27c %11f %11f %11f %11f %11f %11f %11f %11f %11f %11f %11f %11f');
apfdata.V_cl1.HI=d{1};
apfdata.V_cl2.HI=d{2};
apfdata.M_cl.HI=d{3};
apfdata.V_cr1.HI=d{4};
apfdata.V_cr2.HI=d{5};
apfdata.M_cr.HI=d{6};
apfdata.M_des.HI=d{7};
apfdata.V_des2.HI=d{8};
apfdata.V_des1.HI=d{9};


end

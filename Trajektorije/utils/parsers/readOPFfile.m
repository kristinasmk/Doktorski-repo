function [opsdata] = readOPFfile(opsfilename)
%Parses BADA OPF file and returns struct with data.
%
%Input:
%       opsfilename - filename of the OPF file to be parsed
%
%Output:
%       opsdata - struct with all data read from the OPF file

fid = fopen(opsfilename);

data = textscan(fid,'%s','delimiter',{'\n'});

a = textscan(char(data{1,1}(19)), '%*6c %11f %11f %11f %11f %11f');
opsdata.mref = a{1};
opsdata.mmin = a{2};
opsdata.mmax = a{3};
opsdata.mpyld = a{4};
opsdata.gw = a{5};

b = textscan(char(data{1,1}(22)), '%*6c %11f %11f %11f %11f %11f');
opsdata.VMO = b{1};
opsdata.MMO = b{2};
opsdata.maxalt = b{3};
opsdata.Hmax = b{4};
opsdata.tempgrad = b{5};

c = textscan(char(data{1,1}(26)), '%*6c %11f %11f %11f %11f');
opsdata.wingsurf = c{1};
opsdata.Clbo = c{2};
opsdata.k = c{3};
opsdata.CM16 = c{4};

d = textscan(char(data{1,1}(29)), '%*17c %11f %11f %11f');
opsdata.Vstall.CR = d{1};
opsdata.Cd0.CR = d{2};
opsdata.Cd2.CR = d{3};

e = textscan(char(data{1,1}(30)), '%*17c %11f %11f %11f');
opsdata.Vstall.IC = e{1};
opsdata.Cd0.IC = e{2};
opsdata.Cd2.IC = e{3};

f = textscan(char(data{1,1}(31)), '%*17c %11f %11f %11f');
opsdata.Vstall.TO = f{1};
opsdata.Cd0.TO = f{2};
opsdata.Cd2.TO = f{3};

g = textscan(char(data{1,1}(32)), '%*17c %11f %11f %11f');
opsdata.Vstall.AP = g{1};
opsdata.Cd0.AP = g{2};
opsdata.Cd2.AP = g{3};

h = textscan(char(data{1,1}(33)), '%*17c %11f %11f %11f');
opsdata.Vstall.LD = h{1};
opsdata.Cd0.LD = h{2};
opsdata.Cd2.LD = h{3};

i = textscan(char(data{1,1}(39)), '%*28c %11f');
opsdata.Cd0.geardown = i{1};

j = textscan(char(data{1,1}(45)), '%*6c %11f %11f %11f %11f %11f');
opsdata.Ctc1 = j{1};
opsdata.Ctc2 = j{2};
opsdata.Ctc3 = j{3};
opsdata.Ctc4 = j{4};
opsdata.Ctc5 = j{5};

k = textscan(char(data{1,1}(47)), '%*6c %11f %11f %11f %11f %11f');
opsdata.Ctdeslow = k{1};
opsdata.Ctdeshi = k{2};
opsdata.Hpdes = k{3};
opsdata.Ctdesapp = k{4};
opsdata.Ctdesld = k{5};

l = textscan(char(data{1,1}(49)), '%*6c %11f %11f');
opsdata.Vdesref = l{1};
opsdata.Mdesref = l{2};

m = textscan(char(data{1,1}(52)), '%*6c %11f %11f');
opsdata.Cf1 = m{1};
opsdata.Cf2 = m{2};

n = textscan(char(data{1,1}(54)), '%*6c %11f %11f');
opsdata.Cf3 = n{1};
opsdata.Cf4 = n{2};

o = textscan(char(data{1,1}(56)), '%*6c %11f');
opsdata.Cfcr = o{1};

p = textscan(char(data{1,1}(59)), '%*6c %11f %11f %11f %11f');
opsdata.TOL = p{1};
opsdata.LDL = p{2};
opsdata.span = p{3};
opsdata.length = p{4};

q=textscan(char(data{1,1}(14)), '%*5c %s %d8 %s %s %s');
opsdata.actype=string(q{1});
opsdata.numengines=q{2};
opsdata.engtype=string(q{4});
opsdata.wakecat=string(q{5});
end
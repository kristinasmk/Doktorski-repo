function [HHMMSS] = time_HHMMSS (t)  


a=num2str(floor(t/3600));
b=num2str(floor((t/3600- floor(t/3600))*60));
c=num2str(floor(((t/3600- floor(t/3600))*60 - floor((t/3600- floor(t/3600))*60))*60));

if length (a) == 1
    a=['0' a];
end

if length (b) == 1
    b=['0' b];
end

if length (c) == 1
    c=['0' c];
end

HHMMSS=[a b c];

end
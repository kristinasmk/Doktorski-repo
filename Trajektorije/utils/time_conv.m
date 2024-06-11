function time_sec = time_conv (time_HHMMSS)
%function to convert time in HHMMSS format to seconds  

etime_ch=char(time_HHMMSS);     %conversion from text to characters

hh_ch=etime_ch(:,1:2);      %parsing hours
mm_ch=etime_ch(:,3:4);      %parsing minutes
ss_ch=etime_ch(:,5:6);      %parsing seconds

hh_ar=str2num(hh_ch);    %conversion from characters to number
mm_ar=str2num(mm_ch);
ss_ar=str2num(ss_ch);

time_sec=hh_ar*3600+mm_ar*60+ss_ar;   %time of arrival on segmet in seconds
end
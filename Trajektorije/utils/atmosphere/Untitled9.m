% h=0:1000:10000;
% for i=1:size(h,2)
% p(i)=PressureAtHp(const, h(i));
% end

% Da=2746116;
% Db=1430718;
% lata=40;
% b=acosd((Db/Da)*cosd(lata));
p=0:1:101325;
h=((p).^(1/5.25588)/101325+1)/( - 2.25577^(-5));
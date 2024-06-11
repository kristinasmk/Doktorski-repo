function FD = DragForce(dragcoefficient, TAS, airdensity, wingarea)
%{

Calculation of drag force. Returns drag force in newtons. Eq. 3.6-5

dragcoefficient - Drag coefficient. [dimensionless]
TAS - True air speed. [m/s]
airdensity - Air density. [kg/m3]
wingarea - Area of wings. [m2]

%}

FD = (dragcoefficient * TAS * TAS * airdensity * wingarea) / 2;

end
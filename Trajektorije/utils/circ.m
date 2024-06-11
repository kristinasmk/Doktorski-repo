function krug = circ (center, radius)
%funckija za crtanje kruga
%radius mora biti u stupnjevima (nm2deg)
angle = 0:.01:2*pi;
    r = radius;
       X = r.*cos(angle)+ center(1);
       Y = r.*sin(angle)+ center(2);
krug=[Y' X'];
krug=[krug;[Y(1) X(1)]];
end
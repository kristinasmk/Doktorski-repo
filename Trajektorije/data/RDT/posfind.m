function position = posfind (point, pointscale)
% this finction will find closest position of point on defined scale

pos=abs(pointscale-point);
[~,position]=min(pos);

end
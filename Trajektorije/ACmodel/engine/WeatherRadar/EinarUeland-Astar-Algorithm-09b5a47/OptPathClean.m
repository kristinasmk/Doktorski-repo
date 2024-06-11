function OptPathC = OptPathClean (OptimalPath,GoalX,GoalY)
%this function will clean errors in pathfinding for astar
Start=OptimalPath(1,:);

A=OptimalPath(:,1)==Start(1) & OptimalPath(:,2)==Start(2);
B=OptimalPath(:,1)==GoalY & OptimalPath(:,2)==GoalX;

fA=find(A(:,1)==1);
fB=find(B(:,1)==1);


if length(fA)>1 
    fA=fA(2);
end

if length(fB)>1
    fB=fB(1);
end

OptPathC=OptimalPath((fA:fB),:);

end
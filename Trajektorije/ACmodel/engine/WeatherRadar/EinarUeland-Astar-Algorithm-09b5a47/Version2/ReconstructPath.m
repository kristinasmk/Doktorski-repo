function [OptimalPath]=ReconstructPath(CurrentX,CurrentY,ParentX,ParentY,StartX,StartY)
k=2;
    OptimalPath(1,:)=[CurrentY CurrentX];
    RECONSTRUCTPATH=1;
    while RECONSTRUCTPATH
        
        if (((CurrentX== StartX)) &&(CurrentY==StartY))
            break
        end
        CurrentXDummy=ParentX(CurrentY,CurrentX);
        CurrentY=ParentY(CurrentY,CurrentX);
        CurrentX=CurrentXDummy;
        OptimalPath(k,:)=[CurrentY CurrentX];
        k=k+1;

    end
end

function cloudMap = cloudM (Clouds)

Cl=Clouds{(1)};
 
CloudsAll=Cl;    
    
for i=2:size(Clouds,2)

    Cl=Clouds{(i)};
    
    CloudsAll=[CloudsAll;[NaN NaN NaN];Cl];
    

end

end
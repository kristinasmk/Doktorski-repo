%extracting unique RGB color bands:
%load image
Test=imread('test.tif');

%select rbg bands
Clouds=(Test(:,:,1:3));
i=1;
for x=1:size(Clouds,1)
    for y=1:size(Clouds,2)
        RGB(i,:)=[Clouds(x,y,1),Clouds(x,y,2),Clouds(x,y,3)];
        i=i+1;
    end
end
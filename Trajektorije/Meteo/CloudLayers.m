function [Cloudsmask] = CloudLayers (CloudsRGB,RGBalt)


RGBimage=permute(CloudsRGB,[3,1,2]);
m=zeros(size(CloudsRGB,1),size(CloudsRGB,2),size(RGBalt,1));
for n=1:size(RGBalt,1)
    for i=1:size(RGBimage,3)
        
        a=RGBimage(:,:,i)==RGBalt(n,:)';
        s=sum(a)>2;
        s=s';
        m(:,i,n)=s;
    end

end

Cloudsmask=logical(m);
end
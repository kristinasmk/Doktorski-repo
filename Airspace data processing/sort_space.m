function [structure,struct_list]=sort_space(space,n)
addpath(genpath(fileparts(pwd)))


%struc je izlazna struktora airblocka
% n su redovi koji æe se zadržati

confs=strcmp(space(:,1),'');
posco=find(confs<1);
struct_list=space(posco);
structure(numel(posco)-1)=struct();

    for co=2:numel(posco)
        config=space(posco(co-1)+1:posco(co)-1,n);
        structure(co-1).name=struct_list(co-1);
        structure(co-1).parts=config;
    end

struct_list=struct_list(1:end-1,:);
end
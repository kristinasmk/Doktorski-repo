%Complexity calculation using PRU complexity

clear
addpath(genpath(pwd))

load TPgrid2.mat
load LOVVmask.mat
%time raster of traffic samples (must be same as one used in TraffSampling
%script
raster=60;
window=20;  %5 minute sliding windos
duration=8*60; %duration of simulation (60 minutes)
tstart=12*60*60; %time of start of PRU timeframe in seconds (starting from 12:00 hours
ticks=tstart:window*60:tstart+duration*60;

%PRUgrid
[grids,polygon,dims] = gridcreate (10,45,18,50,20,100,450);

%This loop will calculate complexity for n number of randomly 
%generated scenarios scenarios
n=100;
%extracting opening times of each configuration according to given excel
%spreadsheet
%conftime=[sconfs{:,1}]';
configmask={C};
%creating binary matric of available aircraft TPs for random function
for i=1:size(TP)
%AvailAC(i,1)={ones(size(TP{i,1}))};
AvailAC(i,1)={repmat(1:5,size(TP{i,1},1),1)};
end

%for logging indicator values
Mindi=cell(n,length(ticks));
%for logging complexity values
Cplx=cell(n,length(ticks));
tic
for t=1:15 %for every weather scenario
    tic
    for i=1:n
        %create empty PRUgrid 
        PRUgrid=cell(dims(1)*dims(2),36,4);  %there are 36 vertical cells and dims(1)*dims(2) horisontal
        for a=1:size(TP,1) %for every aircraft

            %random ac function
            [randomAC,newusedACdata] = randomACf (AvailAC{a,1},t);
            AvailAC(a,1)={newusedACdata};
            ts=randomAC(1);
            sf=randomAC(2);
            UsedAC(a,1)=ts;
            UsedAC(a,2)=sf;
            %for every PRU grid horisontla shift
            for p=1:4 
    
                %select AC grid data according to created random indexes
                if size(TP{a,p},1)==1
            ACgd=TP{a,p}{ts,sf};
                else
                    ACgd=TP{a,p}{ts,sf};
                end
                
                if ~isempty(ACgd)
                    for c=1:size(ACgd,1)
                         hc=ACgd(c,11); %horizontal cell index
                         vc=ACgd(c,12); %vertical cell index
                        %fill PRG grid cells with AC data is counted in
                        %3000ft cells ac on one FL will affect upper FL and
                        %lower FL cell
                        if vc>1 && vc<36
                         PRUgrid(hc,vc-1,p)={[PRUgrid{hc,vc-1,p};ACgd(c,:)]};
                         PRUgrid(hc,vc,p)={[PRUgrid{hc,vc,p};ACgd(c,:)]}; 
                         PRUgrid(hc,vc+1,p)={[PRUgrid{hc,vc+1,p};ACgd(c,:)]}; 
                        elseif vc==1
                         PRUgrid(hc,vc,p)={[PRUgrid{hc,vc,p};ACgd(c,:)]}; 
                         PRUgrid(hc,vc+1,p)={[PRUgrid{hc,vc+1,p};ACgd(c,:)]};                             
                        elseif vc==36
                         PRUgrid(hc,vc-1,p)={[PRUgrid{hc,vc-1,p};ACgd(c,:)]};
                         PRUgrid(hc,vc,p)={[PRUgrid{hc,vc,p};ACgd(c,:)]};                            
                        elseif vc==0
                         PRUgrid(hc,vc+1,p)={[PRUgrid{hc,vc+1,p};ACgd(c,:)]};                          
                        elseif vc==37
                         PRUgrid(hc,vc-1,p)={[PRUgrid{hc,vc-1,p};ACgd(c,:)]};   
                        end
                            
                    end                    
                end
            end
        end
        %calculating PRU complexty of generated traffic scenario
        %preparation for caclculation of PRU
        y=1;
        for tim=tstart:window*60:tstart+duration*60
        
        %wrapper primjenjuje calcindif na sve æelije
        wrapper = @(x) calcindif(x,tim,raster);
        %calculate indicators
        PRUindicators=cellfun( wrapper, PRUgrid , 'UniformOutput', false);
        % Mindi(i,y)={PRUindicators};
        
        %change indicators from cell to double
        [cplxindD]= indibreak (PRUindicators);
        CPLX(y)={cplxindD};
        %slecting configuration mask according to starting time of
        %complexity calculation 
%         st=conftime((conftime-tim)<=0);
%         configmask=sconfs{conftime==st(end),4};
        
        %calculate complexity accoding to configuration masks
        [cplx,cplxpc] = PRUcomplexf (cplxindD,configmask);
        Cplx(i,y,t)={cplx};
        Cplxpc(i,y,t)={cplxpc};
        y=y+1;
        end
      ACscenario(i,t)={UsedAC};
    end
    toc

end

% cp=[];
% for i=1:15
%     cp=[cp;cellfun(@(v)v(1),Cplx(:,:,i))];
% end
%to extract complexity for single sector use following code: cellfun(@(v)v(1),C)
CplxpcP1=Cplxpc(1:50,:,:);
CplxpcP2=Cplxpc(51:100,:,:);
save ('ComplexityLOVVNAVSIM_P1', 'CplxpcP1')
save ('ComplexityLOVVNAVSIM_P1', 'CplxpcP2')
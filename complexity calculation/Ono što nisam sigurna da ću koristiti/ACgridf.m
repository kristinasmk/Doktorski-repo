function [ACAgrid4D] = ACgridf (TPdata,polygon,dims,Traster,cloudGrid3D,S,E)
%this function will sort AC simulated data logs and fit them in PRU grid
%for calculation of complexity indicators.
%  Input:
   %        Traster - time raster of cells in minutes
   %        altscale - from grid.alt dimensions
%
%  Output: Grid filled with fallowing data 
%           ACdata - cell matrix with fallowing row data
%                   1. ACid            
%                   2. time in cell
%                   3. AC vertical mode
   
%vremenski raster �elija po Tcell vremenu izra�unato u sec
timesc=0:Traster*60:86400;
timescale=timesc(S):Traster*60:timesc(E);

altscale=(100:10:420)*0.3048*100;
ACAgrid4D=cell(size(timescale,2)-1,1);
A=cell(dims(1)*dims(2),4);
B=cell(size(altscale,2),1);
%kreiranje praznih �elija za spajanje
for x1=1:size(timescale,2)-1
    ACAgrid4D{x1,1}=A;
    for x2=1:size(A,1)
        for x3=1:4
            ACAgrid4D{x1,1}{x2,x3}=B;
        end
    end
end

%kre�e petlja za svaku zrakoplov
    for a=1:size(TPdata,2) 
        ACdata=TPdata(a).data;
        ACname=TPdata(a).name;
        ACgrid4D=cell(size(timescale,2)-1,1);
        
        %kre�e petlja za svaki vremenski period
        for t=1:size(timescale,2)-1
            
            ACtimeseg=timescale(t)<=ACdata(:,21) & ACdata(:,21)<timescale(t+1);
            ACtimeseg=ACdata(ACtimeseg,:);
            
            %selecting Cloud data according to time
            if timescale(t)>=cloudGrid3D{1,1} && timescale(t)<=cloudGrid3D{end,1}
            [~,Clouds]=max([cloudGrid3D{:,1}]>timescale(t)); %this fill find upcoming cloud logs, for current -1 
            Clouds=cloudGrid3D{Clouds-1,2}; % -1 is to load current and not next log
            else
                Clouds=[];
            end
            
            if ~isempty(ACtimeseg)  %if AC did not fly in selected time frame
                % ACindexPRU=cell(4,1);
                ACindex=cell(dims(1)*dims(2),4); %for size of p (4 cell shifts)
                
                %kre�e petlja za svaki pomak grida
                for p=1:4
                    
                    %fit ACdata to polygons
                    [in, index] = inpolygons(ACtimeseg(:,1),ACtimeseg(:,2),polygon.xaxis(p,:),polygon.yaxis(p,:));
                    
                    if max(in)>0
                        index=[index{in}]';
                        UniI=unique(index);
                        Uni2D=zeros(dims(1)*dims(2),1);
                        %findinf position in PRU 2D grid columns and rows of ac positions in grid 
                        Uni2D(UniI)=1;
                        Uni2D=reshape(Uni2D,dims(2),dims(1));
                        [c,r]=find(Uni2D);
                        
                        for d=1:size(UniI,1)
                            %positioning in vertical dimension; selecting
                            % vertical column of cells 
                            ACCol=ACtimeseg(index==UniI(d),[3,5,4,1,2]);
                            ACcolA=cell(size(altscale,2),8);
                            
                            for al=1:size(altscale,2)
                                Vpos=ACCol(:,1)>=(altscale(al)-457.2) & ACCol(:,1)<(altscale(al)+457.2); %457.2m is 15FL, ovdje za svaku trajektoriju uklju�uje 3000 ft vertikalno �elije
                            
                                if max(Vpos)>0
                                                        
                                    %extracting AC data at cell altitude
                                    ACM=ACCol(Vpos,:);
                                    
                                    %logging ac name
                                    ACcell(1)={ACname};
                                    
                                    %calculate time spent in cells in seconds since 1 line is 1 sec
                                    %number of lines is time spent in cell
                                    ACcell(2)={size(ACM,1)};
                                    
                                    %calculating vertical mode
                                    %calculate rate of change flown in next 5 seconds or less
                                    %if ac was less than 5 seconds in cell
                                    if size(ACM,1)>5
                                        rate=(ACM(5,1)-ACM(1,1))/5*60/0.3048;%bitno je samo kakav je stva zrakoplova u trenutku ulaska u �eliju
                                    else
                                        rate=(ACM(size(ACM,1),1)-ACM(1,1))/size(ACM,1)*60/0.3048;
                                    end
                                    % vertical mode marking 0-climb 1-descent 2-cruise
                                    if rate>=500
                                        Vmode=0;
                                    elseif rate <= -500
                                        Vmode=1;
                                    else
                                        Vmode=2;
                                    end

                                    ACcell(3)={Vmode};

                                    %logging entry Heading for horizontal
                                    %interactions in aeronatical degrees
                                    ACcell(4)={MathtoNavAngle(ACM(1,2))};

                                    %logging average TAS in cell in knots
                                    ACcell(5)={mean(ACM(:,3))*3600/1852};
                                    
                                    %logging AC-Cloud interaction
                                    if ~isempty(Clouds)
                                        ACcell(6)={AC_cloudf([r(d),c(d),al],Clouds(:,:,:,p))}; %ova funkcija tra�i susjedne �elije i gleda ima li oblaka u trenutnoj ili susjednoj �eliji
                                    else
                                        ACcell(6)={0};
                                    end
                                    ACcell(7)={[r(d),c(d)]};
                                    ACcell(8)={[ACM(round(size(ACM,1)/2),4),ACM(round(size(ACM,1)/2),5)]};
                                    ACcolA(al)={ACcell};
                                end
                            end
                            
                            ACindex(UniI(d),p)={ACcolA}; %all cells are in one line, for visualisation they can be rashaped
                        end
                    end
                    %this will change order of cells to look like PRU grid
                    %over specified area for cloud detection
                    % CindexPRUsq=flip(rot90(reshape(~cellfun('isempty', ACindex(:,p)),dims(2),dims(1))));

                     
                     %ACindexPRU(p)={ACindexPRUsq};
                end
                
                %log all timeframe data
                ACgrid4D(t,1)={ACindex};
                % ACgrid4D(t,2)={ACindexPRU};
            end
            
        end
        
        %fitting all ACs to one pru grid
        for t=1:size(timescale,2)-1
            for p=1:4
                if ~isempty(ACgrid4D{t,1})
                    ACG=ACgrid4D{t,1}(:,p);
                    
                    for c=1:size(ACG,1)
                       if ~isempty(ACG{c})
                           ACGh=ACG{c};
                           for s=1:size(ACGh,1)
                               if ~isempty(ACGh{s})
                                    ACAgrid4D{t,1}{c,p}{s,1}=[ACAgrid4D{t,1}{c,p}{s,1};ACgrid4D{t,1}{c,p}{s,1}];
                               end
                           end
                        
                       end 
                    end                    
                end

            end
        end
    end
end
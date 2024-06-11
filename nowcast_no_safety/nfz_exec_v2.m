function [nfz_cell] = nfz_exec_v2(nowcast,SM)
%Mediante esta función generamos las zonas a evitar a partir de un Nowcast
%probabilístico con un enfoque de ensemble:
%Using this function we generate the areas to avoid from a probabilistic Nowcast with an ensemble approach:

%load 'D:\USE\nowcast_no_safety\nowcast_without_margin.mat'
%Parameters:
%SM = 10;
R_E = 6371/1.852;           %Earth radius   [NM]

n_t = length(nowcast.lead_times);        % Number of lead times.
n_m = length(nowcast.nowcast_members);   % Number of ensemble members.

nfz_cell  = cell(n_t,n_m);

for ii=1:n_t
    for jj=1:n_m
        disp([num2str(ii) ' - ' num2str(jj)]),
        
        %1) Identifying separate polygons:
        Lon_acc = nowcast.geometries(ii,jj).LON;
        Lat_acc = nowcast.geometries(ii,jj).LAT;
        n_p     = 1+sum(isnan(Lon_acc));            %Number of identified storm cells.
        ind_nan = [0;find(isnan(Lon_acc));length(Lon_acc)+1];
        pols_p  = struct('Lon',cell(n_p,1),'Lat',cell(n_p,1));
        for kk=1:n_p
            pols_p(kk).Lon  = Lon_acc(ind_nan(kk)+1:ind_nan(kk+1)-1);
            pols_p(kk).Lat  = Lat_acc(ind_nan(kk)+1:ind_nan(kk+1)-1);
        end
        
        %figure(100*ii+jj), hold on, plot(Lon_acc,Lat_acc,'k','LineWidth',1)
        clear Lon_acc Lat_acc
        
        %1) Enlarging polygons with the safety margin: 
%         figure, hold on,
        for kk=1:n_p
%             plot(pols_p(kk).Lon,pols_p(kk).Lat)
            lat_mean = mean(pols_p(kk).Lat);
            lon_mean = mean(pols_p(kk).Lon);
            x_pol = (pols_p(kk).Lon-lon_mean)*cosd(lat_mean);
            y_pol = pols_p(kk).Lat-lat_mean;
            
            [D_y, D_x]      = bufferm(y_pol,x_pol,180/pi*SM/R_E,'outPlusInterior');
            pols_p(kk).Lat = D_y + lat_mean;
            pols_p(kk).Lon = D_x/cosd(lat_mean) + lon_mean;
%             plot(pols_p(kk).Lon,pols_p(kk).Lat)
        end
        
        %2) Merging polygons:
        Lon_acc = pols_p(1).Lon;
        Lat_acc = pols_p(1).Lat;
        for kk=2:n_p
            [Lon_acc,Lat_acc] = polybool('union',Lon_acc,Lat_acc,pols_p(kk).Lon,pols_p(kk).Lat);
        end
        
        %3) Retrieving separate polygons:
        n_p2     = 1+sum(isnan(Lon_acc));
        ind_nan = [0;find(isnan(Lon_acc));length(Lon_acc)+1];
        pols_p2 = struct('Lon',cell(n_p2,1),'Lat',cell(n_p2,1));
        for kk=1:n_p2
            pols_p2(kk).Lon = Lon_acc(ind_nan(kk)+1:ind_nan(kk+1)-1);
            pols_p2(kk).Lat = Lat_acc(ind_nan(kk)+1:ind_nan(kk+1)-1);
        end
        
        %4) Filtering out polygons inside other polygons:
        in_vec = false(n_p2,1);
        for j_p=1:n_p2
            %Is j_p in another polygon?
            bb = (1:n_p2)';
            bb = bb(bb~=j_p);
            inpol = false;
            for ll = 1:length(bb)
                kk = bb(ll);
                inthispol = inpolygon(pols_p2(j_p).Lon,pols_p2(j_p).Lat,pols_p2(kk).Lon,pols_p2(kk).Lat);
                inthispol = prod(inthispol);
                inpol     = or(inpol,inthispol);
            end
            in_vec(j_p) = inpol;
        end
        pols_p2(in_vec) = [];
        n_p3  = length(pols_p2);
        
%         %5) Reducing the number of points:
        pols_p3 = pols_p2;
%         for kk=1:n_p3
%             tol_map = 1/120; %Admissible error: 0.5 NM
%             [latout,lonout] = reducem(pols_p2(kk).Lat,pols_p2(kk).Lon,tol_map);
%             pols_p3(kk).Lat   = latout;
%             pols_p3(kk).Lon   = lonout;
%         end
        nfz_cell{ii,jj} = pols_p3;
        numClouds = numel(pols_p3);
        
%         %6) Graphics:
%         Lat_acc = pols_p3(1).Lat;
%         Lon_acc = pols_p3(1).Lon;
%         for kk=2:n_p3
%             Lat_acc = [Lat_acc; NaN; pols_p3(kk).Lat];
%             Lon_acc = [Lon_acc; NaN; pols_p3(kk).Lon];
%         end
%         figure(100*ii+jj), hold on, plot(Lon_acc,Lat_acc,'r','LineWidth',2)
    end
    disp(' ')
end
disp(' ')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

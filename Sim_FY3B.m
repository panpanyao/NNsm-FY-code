%%  ---Sim global FY3B NNsm  2010-2019  grid by grid---

clear all
clc
M=964;N=406;
%% --FY3B TB
input='/mnt/WCL-S920B_home/yaopp/Data/FY-3B/DESCEND';
output='/mnt/WCL-S920B_home/yaopp/program/SMAP_FY';
%% net--global---
load([output,'/train/net/net_global0.mat']);
new_folder = [output,'/sim/FYNNsm']; % FY-3B
mkdir(new_folder);  % mkdir()
pass='D'
for yea=2009:2019
    yea
    load ([input,'/',num2str(yea),'y_',pass,'.mat']);%,'FY_y','FY_y_name');
    TB=FY_y;    clear FY_y;
    TB(TB<150)=nan; TB(TB>350)=nan; % TB=double(TB);
    
    if(mod(yea,4)==0 && mod(yea,100)~=0 || mod(yea,400)==0)
        L=366;
    else
        L=365;
    end
    NNsm_year=zeros(M,N,L,3); %  L=size(NNsm_year,3); % 365 or 366
    
    for j=1:N
        j
        for i=1:M
            net= net_global0{i,j};
            if strcmp(class(net),'double') %%%net=nan
                NNsm_year(i,j,:)=nan;  %
                continue
            elseif strcmp(class(net),'network')
                TB1(1:L,1)=TB(i,j,:,1);  TB2(1:L,1)=TB(i,j,:,2);  TB3(1:L,1)=TB(i,j,:,3);  TB4(1:L,1)=TB(i,j,:,4); TB5(1:L,1)=TB(i,j,:,5);  TB6(1:L,1)=TB(i,j,:,6);  TB7(1:L,1)=TB(i,j,:,7);  TB8(1:L,1)=TB(i,j,:,8);
                %% filter isoutlier
                for c=1:8
                    eval(['A=TB',num2str(c),';'])
                    TF1= isoutlier(A,'median');   A(TF1)=nan;
                    eval(['TB',num2str(c),'=A;'])
                end
                MVI= ( TB4 - TB3  ) ./  (  TB2-TB1);
                %%       %% in the constant value of SMAP, sim(nan)=0.56 , so   add T2(:,index2)=nan;
                index2=  isnan(MVI)|isnan(TB1)|isnan(TB2)| isnan(TB3)| isnan(TB4)|isnan(TB5)| isnan(TB6)|isnan(TB7)|isnan(TB8);
                index2=index2';
                P2 =[ TB1, TB2,TB3 , TB4 ,  TB5, TB6,TB7 , TB8,MVI  ]';%
                P2(:,index2)=nan;
                T2=sim(net,P2);
                T2(index2)=nan;
                T2(T2<=0 | T2 >1)=nan;
                T2(T2>0&T2<0.02)=0.02;
                T2(T2>0.6&T2<1)=0.6;
                
                A=T2;
                TF1= isoutlier(A,'median'); B=A;   B(TF1)=nan;%'quartiles' better than 'median'    %     BB= filloutliers(A,'linear','median');%'
                TF2=isoutlier(A,'movmedian',30) ;    C=A; C(TF2)=nan;  %      [C,TF,~,U,Cen]=filloutliers(B,'linear','movmedian',8) ;
                NNsm_year(i,j,:,1)=T2;
                NNsm_year(i,j,:,2)=B;
                NNsm_year(i,j,:,3)=C;
                clear P2 T2 A B C
            end
        end
    end
    NNsm_year=single(NNsm_year);
    save([output,'/sim/FYNNsm/NNsm_year',num2str(yea),'.mat'],'NNsm_year');%FY-3B
end



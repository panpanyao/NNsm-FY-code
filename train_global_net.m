clear
clc
M=964;N=406;
input='/mnt/WCL-S920B_home/yaopp/program/SMAP_FY/train';
load([input,'/match_data.mat']);%,'SM','TB','data_date');
% TB      964         406        1006          12
% SM   406*964  1006
% L=1006

net_global=cell(M,N);
bias=zeros(M,N);
rmse=zeros(M,N);
RR=zeros(M,N);
ts_threshold=zeros(M,N);
net_flag_N=zeros(M,N);
SMAP=cell(M,N);
NN=cell(M,N);
TB(TB<150)=nan; TB(TB>350)=nan;
aaa=1;
for j=1:N
    j
    for  i=1:M
        clear sm TB37v  ts  TB1 TB2 TB3 TB4  TB5 TB6 TB7 TB8 TB9 MVI
        TB37v(:,1)=TB(i,j,:,8);TB37v(TB37v==0)=nan;
        L=length(TB37v);
        kk=1;
        
        sm(1:L,1)=SM(i,j,:);sm=double(sm); sm(sm==0)=nan;
        ts=1.11.*TB37v-15.2;%  TB 37v %% ts=1.16.*TB37v-32.11;
        ts(ts<=273.15-10*(kk-1)| isnan(ts))=nan; %%% frozen
        
        TB1(1:L,1)=TB(i,j,:,1);  TB2(1:L,1)=TB(i,j,:,2);  TB3(1:L,1)=TB(i,j,:,3);  TB4(1:L,1)=TB(i,j,:,4); TB5(1:L,1)=TB(i,j,:,5);  TB6(1:L,1)=TB(i,j,:,6);  TB7(1:L,1)=TB(i,j,:,7);  TB8(1:L,1)=TB(i,j,:,8);
        %% filter isoutlier
        for c=1:8
            eval(['A=TB',num2str(c),';'])
            TF1= isoutlier(A,'median');   A(TF1)=nan;
            eval(['TB',num2str(c),'=A;'])
        end
        
        MVI= ( TB4 - TB3  ) ./  (  TB2-TB1);
        R=zeros(L,10);
        TB_tmp=zeros(L,10);
        for c=1:8
            TB0(:,1)=TB(i,j,:,1);TB0(TB0==0)=nan;
            tmp= TB0./TB37v;
            R(:,c)=tmp;
            TB_tmp(:,c)=TB0;
            clear TB0 tmp
        end
        
        index=  isnan(sm)  |isnan(TB1)|isnan(TB2)| isnan(TB3)| isnan(TB4)|isnan(TB5)| isnan(TB6)|isnan(TB7)|isnan(TB8);% ..
        sm(index)=[];
        MVI(index)=[];
        for c=1:8
            eval(['TB',num2str(c),'(index)=[];'])
        end
        Num=length(sm);
        
        if Num<50
            net_global{i,j}=nan; bias(i,j)=nan;rmse(i,j)=nan;RR(i,j)=nan;
            SMAP{i,j}=sm' ;
            NN{i,j}=nan;
            net_flag_N(i,j)=0;
            continue
        end
        
        P=[ TB1, TB2,TB3 , TB4 ,  TB5, TB6,TB7 , TB8,MVI  ]';%
        T=sm';%
        
        tmprmse=[];
        net_tmp=cell(5,1);
        for tt=1:5
            net=cascadeforwardnet(10);%
            net.trainParam.epochs = 50; %
            NET = train(net,P,T);
            T2 = NET(P);
            tmprmse(tt)=sqrt(sum((T-T2).^2)/length(T));
            net_tmp{tt,1}=NET;
            perf = perform(NET,T2,T);
        end
        index_net=find(tmprmse == min(tmprmse));
        NET=net_tmp{index_net,1};
        T2 =NET(P);
        net_global{i,j}=NET;
        net_flag_N(i,j)=1;
        
        bias_nn=sm'-T2;bias(i,j)=mean(bias_nn);
        rmse(i,j)=sqrt(sum(bias_nn.^2)/length(sm'));
        corr=corrcoef(sm',T2);RR(i,j)=corr(1,2);%corr(1,2)
        SMAP{i,j}=sm' ;
        NN{i,j}=T2;
        
    end
    
    
    
end

save([input,'/net/SMAP',num2str(aaa),'.mat'],'SMAP');
save([input,'/net/NN',num2str(aaa),'.mat'],'NN');
save([input,'/net/net_global',num2str(aaa),'.mat'],'net_global');
save([input,'/net/bias',num2str(aaa),'.mat'],'bias');
save([input,'/net/rmse',num2str(aaa),'.mat'],'rmse');
save([input,'/net/RR',num2str(aaa),'.mat'],'RR');
save([input,'/net/net_flag_N',num2str(aaa),'.mat'],'net_flag_N');%net_flag_N(i,1)=1; %%������


close all
clear net NET


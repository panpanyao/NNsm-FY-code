%% match SMAP SSM and FY-3 TB

%%   2015-2017, 3years in total [2015 2016 2017 ]
M=964;N=406;
input='/home/yaopp/program/SMAP_NN/data_process/SMAP_SMP';
input2='/mnt/WCL-S920B_home/yaopp/Data/FY-3B/DESCEND'; % FY3B-36
output='/mnt/WCL-S920B_home/yaopp/program/SMAP_FY/train';
SM=[];TB=[];data_date=[];

for p=1%:2  %%%P=1 SMAP 6:00 AMSR 1:30  D
    p
    if p==1
       pass='D';k0=0;% pass_AMSRE='D';pass_SMAP='D';  
    elseif p==2
       pass='A';k0=1095;% pass_AMSRE='A';pass_SMAP='A';  k0=1095; %%730
    end
 
    for yea=[2015 2016 2017]
        yea
        if(mod(yea,4)==0 && mod(yea,100)~=0 || mod(yea,400)==0)
            L=366;
        else
            L=365;
        end
        load ([input,'/year_ave/',num2str(yea),'y_',pass,'.mat'],'smap_y','smap_y_name');
        load ([input2,'/',num2str(yea),'y_',pass,'.mat']);%,'FY_y','FY_y_name');

        s=1;
        SM=cat(3,SM,smap_y);
        TB=cat(3,TB,FY_y(:,:,s:end,:));
        data_date=[data_date;FY_y_name];
        
    end
end

save([output,'/match_data.mat'],'SM','TB','data_date');
 

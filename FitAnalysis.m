% Work with google takeout google fit data
close all; clear; clc;

indir='C:\Users\sshekhar\Documents\Sid-Personal\googlefit\Takeout\Fit\Activities';
activity='Cycling';

A=dir([indir,'\','*',activity,'.tcx']);
%% Calculate
V=0;
Vavg=0;
T=0;
TT=0;
V1=0;
V_box=0;


clc;

k=1;
f=waitbar(k/length(A),['Processing google fit ',activity,' files...']);
for k=1:length(A)
    clear data distance time hh mm ss v exception
    disp(['Loading ...', indir,'\',A(k).name]);
    data=xml_load([indir,'\',A(k).name]);
    disp('Done.');
    disp(['Processing ...', indir,'\',A(k).name]);
    
    size(data.Activities);
    try
        for i=1:length(data.Activities.Activity.Lap.Track)
            distance(i)=str2num(data.Activities.Activity.Lap.Track(i).Trackpoint.DistanceMeters);
            time1(i)=datenum([data.Activities.Activity.Lap.Track(i).Trackpoint.Time(1:10),' ',data.Activities.Activity.Lap.Track(i).Trackpoint.Time(12:19)]);
            date{i}=datenum([data.Activities.Activity.Lap.Track(1).Trackpoint.Time(1:10),' ', data.Activities.Activity.Lap.Track(1).Trackpoint.Time(12:19)]);
            %             dn(k)=datenum(date{1});
            format long
            dn(k)=datenum([data.Activities.Activity.Lap.Track(1).Trackpoint.Time(1:10),' ', data.Activities.Activity.Lap.Track(1).Trackpoint.Time(12:19)]);
            
            hh(i)=str2num(data.Activities.Activity.Lap.Track(i).Trackpoint.Time(12:13));
            mm(i)=str2num(data.Activities.Activity.Lap.Track(i).Trackpoint.Time(15:16));
            ss(i)=str2num(data.Activities.Activity.Lap.Track(i).Trackpoint.Time(18:19));
            t=[hh; mm; ss]';
            deltat(i,:)=t(i,:)-t(1,:);
        end
        
        datestring{k}=date{1};
        TotalDistance(k)=str2num(data.Activities.Activity.Lap.DistanceMeters);
        TotalTime(k)=str2num(data.Activities.Activity.Lap.TotalTimeSeconds);
        TotalCalories(k)=str2num(data.Activities.Activity.Lap.Calories);
        
        clear del;
        del(1)=0;elpasedtime(1)=0;v(1)=NaN;tt(1)=0;
        n=2;
        while n<length(hh)
            del(n)=3600*(hh(n)-hh(n-1))+60*(mm(n)-mm(n-1))+(ss(n)-ss(n-1));
            elpasedtime(n)=del(n-1)+del(n);
            tt(n)=time1(n)-time1(1);
            v(n)=(distance(n)-distance(n-1))/del(n);
            
            if or(v(n)==0,v(n)>10)
                v(n)=NaN;
            end
            
            vavg=nanmean(v);
            n=n+1;
        end
        v1=v.^-1*(1000/60); %minutes per km
        
        V=horzcat(V,v);
        
        V1=horzcat(V1,v1);
        Vavg=horzcat(Vavg,vavg);
        
        T=horzcat(T,time1);
        TT=horzcat(TT,tt);
        
        
        %         display(['Finished...',num2str(100*k/length(A)),' %'])
    catch exception
        Vavg=horzcat(Vavg,0);
        %         dn(k)=dn(k-1)+dn(k-1)-dn(k-2);
        display(['Error at ',A(k).name,': ',exception.message]);
        display(['Finished...',num2str(100*k/length(A)),' %'])
    end
    waitbar(k/length(A),f,['Processing google fit ',activity,' files...',num2str(k),' of ' ,num2str(length(A))]);
end
close(f)
%% Visualize
close all;
h=MakeFigure(10);
T(1:(length(T)-length(V)))=[];
V2=V1;
V2(V2>6)=NaN;
plot(T,V2,'x');
datetick('x','keepticks','keeplimits')
% hold on;plot(dn,Vavg,'x');
set(gca,'fontsize',10);
xlabel('Time');
ylabel('Speed (min/km)');
% ylim([0 10]);
title([activity,'-','Average Speed']);
%%

dn(dn==0)=NaN;
TotalDistance(TotalDistance==0)=NaN;
TotalTime(TotalTime==0)=NaN;
TotalCalories(TotalCalories==0)=NaN;

%remove duplicates
i=1;
dn1(1)=dn(1);
while i<length(dn)
    if dn(i+1)==dn(i)
        dn1(i+1)=NaN;
    else dn1(i+1)=dn(i+1);
    end
    i=i+1;
end
%
close all;
h=MakeFigure(randi(10));
plot(dn1,TotalDistance/1000,'x');
set(gca,'XMinorTick','on','YMinorTick','off')
datetick('x',2)
set(gca,'fontsize',10);
xlabel('Date');
ylabel('Total Distance (km)');
title([activity,'-','Total Distance']);
%% Cyclin to work
Dwork=TotalDistance/1000; %in km
Dwork(Dwork<6)=NaN;
Dwork(Dwork>7)=NaN;
if strcmp(activity,'Cycling');
    h=MakeFigure(randi(10));
    plot(dn1,Dwork,'x');
    set(gca,'XMinorTick','on','YMinorTick','off')
    datetick('x',31);
    xlim([7.368*10^5, 7.3705*10^5]);
    
    set(gca,'fontsize',10);
    xlabel('Date');
    ylabel('Total Distance (km)');
    title([activity,'-','Total Distance']);
end
%
h=MakeFigure(randi(10));
scatter(dn,3.6*TotalDistance./TotalTime);
AvgV=(TotalTime/60)./(TotalDistance/1000);
AvgV(AvgV<0.5)=NaN;
AvgV(AvgV>40)=NaN;
% plot(dn,AvgV,'o');
grid on;

datetick('x','keepticks','keeplimits')
set(gca,'fontsize',10);
xlabel('Date');
ylabel('Average Speed (km/hr)');
title([activity,'-','Average Speed']);



% plot(24*3600*T,V1,'x')
% histogram(V);


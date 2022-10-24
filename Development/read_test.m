%% Načíst data
data=readtable("data pro Vlastika_Šablona_2022-10-07.xlsx",'VariableNamingRule','preserve');
%%
% obj=WGGuide("data pro Vlastika_Šablona_2022-10-07.xlsx");
obj=InterFig;
%%

a=log10(1024)
b=power(10,a)
%%
x=obj.WGTabList{1, 2}.WGInterp.FitT.xo{4};
y=obj.WGTabList{1, 2}.WGInterp.FitT.yo{4};
z=obj.WGTabList{1, 2}.WGInterp.FitT.zo{4};
%% Filtrovat pouze VUT

T=data(data.('Laboratoř')=="VUT",:);

TF=FoldTable(T,[6,7,8,38],1:39,'none');

%
idx=[];
for i=1:size(TF,1)
    Tn=TF.FilteredTable{i};
    Tn=rmmissing(Tn);
    if size(Tn,1)==0
        idx(end+1)=i;
    end
end
TF(idx,:)=[];
%%
figure;
hold on;
vy=4;
Ti=TF.FilteredTable{4};
if vy>1
    xnam=sprintf('x%d',vy);
    ynam=sprintf('y%d',vy);
    znam=sprintf('z%d',vy);
    stname=sprintf('std%d',vy);
else
    xnam='x';
    ynam='y';
    znam='z';
    stname='std';
end

x=Ti.(xnam);
y=Ti.(ynam);
z=Ti.(znam);
s=Ti.(stname);

t=Ti.Teplota;
Tm=table(x,y,z,s,t);
unqt=unique(Tm.t);
col=lines(numel(unqt));
for i=1:numel(unqt)
    Tmi=Tm(Tm.t==unqt(i),:);
    [fitresult,gof]=FitGuide.FitProcessedData2(Tmi.x,Tmi.y,Tmi.z);
    
    x1=Tmi.x;
    y1=Tmi.y;
    z1=Tmi.z;

    lx=linspace(min(Tmi.x),max(Tmi.x),10);
    ly=linspace(min(Tmi.y),max(Tmi.y),10);
    scatter3(Tmi.x,Tmi.y,Tmi.z,60,'marker','o','HandleVisibility','off','MarkerFaceColor',col(i,:),'MarkerEdgeColor','none');
    [xx,yy] = meshgrid(lx,ly);
    zz=fitresult(xx,yy);
    surf(xx,yy,zz,'FaceAlpha',0.8,'DisplayName',sprintf("R2:%0.2f T:%d",gof.rsquare,unqt(i)),'FaceColor',col(i,:));
end
legend;
set(gca,'ZScale','log');
view(30,30);

%%
Tii=Ti(Ti.Teplota==20,:);
%%
i=1;
x=TF.FilteredTable{i}.z2;
y=TF.FilteredTable{i+1}.z2;
z=TF.FilteredTable{i}.y2;
l=TF.FilteredTable{i}.legend;
T=TF.FilteredTable{i}.Teplota;
scatter3(x,y,z,10,T,'o','filled');
col=colorbar;
xlabel('Density');
ylabel('Viscosity');
zlabel('K Dry matter');
set(gca,'YScale','log');
%%
TML=table(x,y,z,T,l);
subplot(1,2,1);
scatter3(TML.x,TML.y,TML.z,10,TML.T,'o','filled');
xlabel('Density');
ylabel('Viscosity');
% zlabel('Si4 MS');
zlabel('K drymatter');
title('Teplota');
subplot(1,2,2);
scatter3(TML.x,TML.y,TML.z,10,TML.l,'o','filled');
title('Legend');
xlabel('Density');
ylabel('Viscosity');
zlabel('K drymatter');
%%
TMLi=TML(TML.T==20,:);

scatter3(TMLi.x,TMLi.y,TMLi.z,10,TMLi.l,'o','filled');
%%
TFi=FoldTable(TF.FilteredTable{1},37,1:39,'none');

figure;
hold on;
for i=1:size(TFi,1)
    Ti=TFi.FilteredTable{i};
    sz=size(Ti);
    T=zeros(sz(1),1);
    T(:,1)=TFi.Teplota(i);
    x=Ti.x;
    y=Ti.y;
    z=Ti.z;

    scatter3(x,y,z,10,T,'o','filled');
end
set(gca,'ZScale','log');
%%

T=readtable('data pro Vlastika_Šablona_2022-05-13.xlsx','Sheet','Data',...
    'VariableNamingRule','preserve');
%%

T1=T(:,["x","y","z","std","xlabel","ylabel","zlabel","Teplota","legend"]);
T2=T(:,["x2","y2","z2","std2","x2Label","y2Label","z2Label","Teplota","legend"]);
T3=T(:,["x3","y3","z3","std3","x3Label","y3Label","z3Label","Teplota","legend"]);
T4=T(:,["x4","y4","z4","std4","x4Label","y4Label","z4Label","Teplota","legend"]);

names=T1.Properties.VariableNames;
T2.Properties.VariableNames=names;
T3.Properties.VariableNames=names;
T4.Properties.VariableNames=names;

TF=[T1; T2; T3; T4];
%%
% unqX=unique(TF.xlabel);
% unqY=unique(TF.ylabel);
% unqZ=unique(TF.zlabel);
% unqT=unique(TF.Teplota);
% unqL=unique(TF.legend);

TFF=FoldTable(TF,[5,6,7],[1,2,3,8],'none');
%%

TU=TFF(1:7,1:7);
TL=TFF(8:14,6);
TL.Properties.VariableNames={'Viscosity'};
TT=[TU, TL];
TT.Properties.VariableNames(6)={'Density'};
TT(:,3)=[];
%%
row=5;
axtype='x';

varname=[axtype 'label'];

x=TT.Density{row};
y=TT.Viscosity{row};
z=TT.(axtype){row};
t=TT.Teplota{row};

Ti=table(x,y,z,t,'VariableNames',{'Density','Viscosity',char(TT.(varname)(row)),'Temperature'});

TiTemp=table2array(Ti(Ti.Temperature==25,:));

xt=TiTemp(:,1);
yt=TiTemp(:,2);
zt=TiTemp(:,3);

[fitresult, gof] = createFit(xt, yt, zt);
title(sprintf("sse: %0.4e rsquare: %0.2f",gof.sse,gof.rsquare));

xlabel('Density');
ylabel('Viscosity');
zlabel(TT.(varname)(row));
% xla='Density';
% yla='Viscosity';
% zla=TT.xlabel(1);
% 
% scatter3(x,y,z,60,t,'filled');
% xlabel(xla);
% ylabel(yla);
% zlabel(zla);
% 
set(gca,'YScale','log');
%%
%%
row=3;
axtype='y';

varname=[axtype 'label'];

x=TT.Density{row};
y=TT.x{row};
z=TT.(axtype){row};
t=TT.Teplota{row};

Ti=table(x,y,z,t,'VariableNames',{'Density','Viscosity',char(TT.(varname)(row)),'Temperature'});

TiTemp=table2array(Ti(Ti.Temperature==15,:));

xt=TiTemp(:,1);
yt=TiTemp(:,2);
zt=TiTemp(:,3);

[fitresult, gof] = createFit(xt, yt, zt);
title(sprintf("sse: %0.4e rsquare: %0.2f",gof.sse,gof.rsquare));

xlabel('Density');
ylabel('Viscosity');
zlabel(TT.(varname)(row));
% xla='Density';
% yla='Viscosity';
% zla=TT.xlabel(1);
% 
% scatter3(x,y,z,60,t,'filled');
% xlabel(xla);
% ylabel(yla);
% zlabel(zla);
% 
set(gca,'YScale','log');
%%

Ts=T(T.Teplota==15,:);

Ts.xlabel=string(Ts.xlabel);
Ts.ylabel=string(Ts.ylabel);
Ts.zlabel=string(Ts.zlabel);

Tsi=Ts(Ts.xlabel=="Na+(mol/l)",:);

TsD=Tsi(Tsi.zlabel=='Density',:);
TsV=Tsi(Tsi.zlabel=='Viscosity',:);

xt=TsD.z;
yt=TsV.z;
zt=TsV.x;

[fitresult, gof] = createFit(xt, yt, zt);
title(sprintf("sse: %0.4e rsquare: %0.2f",gof.sse,gof.rsquare));
set(gca,'YScale','log');
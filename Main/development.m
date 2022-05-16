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

TFF=FoldTable(TF,[5,6,7],[1,2,3,8],'mean');
%%

TU=TFF(1:7,1:7);
TL=TFF(8:14,6);
TL.Properties.VariableNames={'z2'};
TT=[TU, TL];
TT.Properties.VariableNames={};
%%
row=13;

x=TFF.z{1};
y=TFF.z{8};
z=TFF.x{8};
t=TFF.Teplota{8};

xla=TFF.zlabel(1);
yla=TFF.zlabel(8);
zla=TFF.xlabel(8);

scatter3(x,y,z,60,t,'filled');
xlabel(xla);
ylabel(yla);
zlabel(zla);

set(gca,'YScale','log');
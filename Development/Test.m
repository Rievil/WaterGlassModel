FG = FitGuide;
R=FG.GetData;
%% What are on x and y axis
% xlabel(obj.MainAx,'Na^{+} (mol/l)');
% ylabel(obj.MainAx,'SiO_{2} (mol/l)');
%%
Tv=R(R.ZType=="v",:);
Th=R(R.ZType=="d",:);

%%
% Viskozita

fig=figure('Position',[0 80 1600 600]);
subplot(1,2,1);
hold on;
box on;
grid on;

t=unique(Tv.T);
col=spring(numel(t));
for i=1:numel(t)
    TvUn=Tv(Tv.T==t(i),:);
    ca=linspace(t(i),t(i),size(TvUn,1))';
    scatter3(TvUn.z,TvUn.x,TvUn.y,[],ca,'Filled');
    
end
cmap=colorbar('Location','northoutside');
colormap(spring(numel(t)));
cmap.Label.String='Teplota T (°C)';
view(45,45);
xlabel('Viskozity');
ylabel('Na');
zlabel('Sio2');

ylim([0,20]);
zlim([0,9]);

% Hustota


subplot(1,2,2);
hold on;
box on;
grid on;
t=unique(Th.T);
col=spring(numel(t));
for i=1:numel(t)
    TvUn=Th(Th.T==t(i),:);
    ca=linspace(t(i),t(i),size(TvUn,1))';
    scatter3(TvUn.z,TvUn.x,TvUn.y,[],ca,'Filled');
    
end
cmap=colorbar('Location','northoutside');
colormap(spring(numel(t)));
cmap.Label.String='Teplota T (°C)';
view(45,45);
xlabel('Hustota');
ylabel('Na');
zlabel('Sio2');
ylim([0,20]);
zlim([0,9]);
%%

figure;


subplot(1,2,1);
hold on;

Tvs=sortrows(Tv,'x');
Ths=sortrows(Th,'x');

plot(Tvs.x,'-o','DisplayName','Na^{+} values in viskozity measurement');
plot(Ths.x,'-o','DisplayName','SiO_{2} values in viskozity measurement');
legend;
subplot(1,2,2);
ylim([0,18]);
hold on;

Tvs=sortrows(Tv,'y');
Ths=sortrows(Th,'y');

plot(Tvs.y,'-o','DisplayName','Na^{+} values in density measurement');
plot(Ths.y,'-o','DisplayName','SiO_{2} values in density measurement');
legend;
ylim([0,18]);



%%

unqx=unique(R.x);
unqy=unique(R.y);
unqt=unique(R.T);



mx=linspace(min(unqx),max(unqx),100)';
my=linspace(min(unqy),max(unqy),100)';
mt=linspace(min(unqt),max(unqt),20)';


%%
OutT=table;
f = waitbar(0,'Please wait...');
n=0;
count=numel(mx)*numel(my)*numel(mt);
for i=1:numel(mx)
    for j=1:numel(my)
        for k=1:numel(mt)
            n=n+1;
            [Zv,accv]=FG.GetZ(mx(i),my(j),mt(k),"v");
            
            [Zd,accd]=FG.GetZ(mx(i),my(j),mt(k),"d");
            
            OutT=[OutT; table(mx(i),my(j),mt(k),Zv,accv,Zd,accd,'VariableNames',...
                {'x','y','t','zv','zvacc','zd','zdacc'})];
            waitbar(n/count,f,sprintf('Loading your data: %d/%d',n,count));
        end
    end
end
%%
load('C:\Users\Richard\OneDrive - Vysoké učení technické v Brně\Měření\2021\WaterGlass\MatriceDensityViskozity.mat');
%%
acc=zeros(size(OutT,1),1);
for i=1:size(OutT,1)
    acc(i,1)=OutT.zdacc(i).rsquare;
end
%
histogram(acc);
%%
% Tst=OutT(OutT.t==15,:);
fig=figure('position',[0 80 1600 800]);
grid on;
box on;
hold on;

scatter3(OutT.zv,OutT.zd,OutT.y,[],OutT.t,'o','Filled');
xlabel('Viskozita');
ylabel('Hustota');
% zlabel('Na2');

% xlabel(obj.MainAx,'Na^{+} (mol/l)');
zlabel('SiO_{2} (mol/l)');

ax=gca;
cmap=colorbar('Location','northoutside');
% colormap(spring(numel(t)));
cmap.Label.String='Teplota (°C)';
view(-28,59);
set(ax,'FontName','Palatino linotype','FontSize',14,'LineWidth',1.5);
print(fig,'Data_big_SIO2','-dpng');
% set(fig,'Renderer','painters');
limA{1}=ax.XLim;
limA{2}=ax.YLim;
limA{3}=ax.ZLim;
%%
% Tst=OutT(OutT.t>22 & OutT.t<24 & OutT.zd>1.28 & OutT.zd<1.32 & OutT.zv>4.9 & OutT.zv<5.1,:);
Tst=OutT(OutT.t>14 & OutT.t<31 & OutT.zd>1.03 & OutT.zd<1.05 & OutT.zv>1.6 & OutT.zv<1.7,:);
fig=figure('position',[0 80 1600 800]);
grid on;
box on;
hold on;

scatter3(Tst.zv,Tst.zd,Tst.y,[],Tst.t,'o','Filled');
xlabel('Viskozita');
ylabel('Hustota');
% zlabel('Na2');

% xlabel(obj.MainAx,'Na^{+} (mol/l)');
zlabel('SiO_{2} (mol/l)');

ax=gca;
cmap=colorbar('Location','northoutside');
% colormap(spring(numel(t)));
cmap.Label.String='Teplota (°C)';
view(-28,59);
caxis([15,30]);
xlim(limA{1});
ylim(limA{2});
zlim(limA{3});
set(ax,'FontName','Palatino linotype','FontSize',14,'LineWidth',1.5);
print(fig,'Data_Selection_SIo2','-dpng');


%%
fig=figure('position',[0 80 1600 800]);
grid on;
box on;
hold on;

scatter3(OutT.zv,OutT.zd,OutT.x,[],OutT.t,'o','Filled');
xlabel('Viskozita');
ylabel('Hustota');
% zlabel('Na2');

% xlabel(obj.MainAx,'Na^{+} (mol/l)');
zlabel('Na^{+} (mol/l)');

ax=gca;
cmap=colorbar('Location','northoutside');
% colormap(spring(numel(t)));
cmap.Label.String='Teplota (°C)';
view(-45,12);
set(ax,'FontName','Palatino linotype','FontSize',14,'LineWidth',1.5);
print(fig,'Data_big_Na2','-dpng');
limB{1}=ax.XLim;
limB{2}=ax.YLim;
limB{3}=ax.ZLim;
%%
Tst=OutT(OutT.t>22 & OutT.t<24 & OutT.zd>1.28 & OutT.zd<1.32 & OutT.zv>4.9 & OutT.zv<5.1,:);
fig=figure('position',[0 80 1600 800]);
grid on;
box on;
hold on;

scatter3(Tst.zv,Tst.zd,Tst.x,[],Tst.t,'o','Filled');
xlabel('Viskozita');
ylabel('Hustota');
% zlabel('Na2');

% xlabel(obj.MainAx,'Na^{+} (mol/l)');
zlabel('Na^{+} (mol/l)');

ax=gca;
cmap=colorbar('Location','northoutside');
% colormap(spring(numel(t)));
cmap.Label.String='Teplota (°C)';
caxis([15,30]);
view(-45,12);
xlim(limB{1});
ylim(limB{2});
zlim(limB{3});

set(ax,'FontName','Palatino linotype','FontSize',14,'LineWidth',1.5);
print(fig,'Data_Selection_Na2','-dpng');
%%

fig=figure;
hold on;
Ts=sortrows(R,'x');
Ts=Ts(Ts.ZType=="v" & Ts.T==15,:);

plot(Ts.x,Ts.y);


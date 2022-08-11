load('MatriceDensityViskozity.mat');
%%
trange=[15,20.526315789473685,25.263157894736842,30];
%% Obsah SiO2
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

%% Obsah Na+
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

%% Contury
fig=figure('position',[0 80 900 800]);
tl=tiledlayout(numel(trange),2);

for tr=1:numel(trange)
    temp=trange(tr);
    T=OutT(OutT.t==temp,:);

    %

    idx=1:1:size(T,1);

    zidxSI = reshape(idx,100,100);
    zidxNA = reshape(idx,100,100);

    zSI = reshape(T.x,100,100);
    zNA = reshape(T.y,100,100);

    arrV=cell(size(zSI));
    arrD=cell(size(zNA));

    for i=1:size(zSI,1)
        for j=1:size(zSI,2)
            x=T.zv(zidxSI(i,j));
            y=T.zd(zidxNA(i,j));

            arrV{i,j}=[arrV{i,j}, x]; %si
            arrD{i,j}=[arrD{i,j}, y]; %na

        end
    end
    %
    zfinV=cell2mat(arrV);
    zfinD=cell2mat(arrD);
    %
    
%     ax=gca;
    nexttile;
    contourf(zfinV,zfinD,zSI,'ShowText','on');
    
    if tr==1
        title('SiO_{2} composition');
    end
    % ax.XAxis.Scale='log';
    % ax.YAxis.Scale='log';
    xlim([0 41]);
    ylim([1 2]);
    c=colorbar;
    c.Label.String=sprintf('SiO_{2} at %d °C (mol/l)',round(temp,0));
%     title(sprintf("Temperature: %d °C",round(temp,0)));
    %
%     fig=figure;
%     ax=gca;
    nexttile;
    contourf(zfinV,zfinD,zNA,'ShowText','on');
    xlim([0 41]);
    ylim([1 2]);
    if tr==1
        title('Na^{+} composition');
    end
%     xlabel('Viscozity (Pa\cdots)');
%     ylabel('Density (g/cm^{3})');
    % ax.XAxis.Scale='log';
    % ax.YAxis.Scale='log';
    % title(sprintf('Water glass Na^{+} composition at %d °C (mol/l)',temp));
    c=colorbar;
    c.Label.String=sprintf('Na^{+} at %d °C (mol/l)',round(temp,0));
end

xlabel(tl,'Viscozity (Pa\cdots)');
ylabel(tl,'Density (g/cm^{3})');
set(fig,'renderer','painters');

%% Trénování modelu

OutTi=OutT(:,["x","y","t","zv","zd"]);
%
OutTi.Properties.VariableNames={'Na','SiO','Temperature','Viscosity','Density'};
OutTi.Properties.VariableUnits={'mol/l','mol/l','°C','','g/cm3'};

%
[SiModel, SiVal] = TrainSiModel(OutTi);
[NaModel, NaVal] = TrainNaModel(OutTi);
%
%% Odhad vybraných veličin
row=15000;
% OutTir=table(NaN,NaN,15,8.80221,1.3367,'VariableNames',{'Na','SiO','Temperature','Viscosity','Density'});
OutTir=OutTi(row,:);
SiGuess = SiModel.predictFcn(OutTir);
NaGuess = NaModel.predictFcn(OutTir);
%% Perform cross-validation
partitionedModel = crossval(SiModel.RegressionTree, 'KFold', 5);

% Compute validation predictions
SiPredict = kfoldPredict(partitionedModel);

partitionedModel = crossval(NaModel.RegressionTree, 'KFold', 5);

% Compute validation predictions
NaPredict = kfoldPredict(partitionedModel);
%
OutG=[OutTi, table(SiPredict,NaPredict)];
% OutG.SiGuessError=abs(1-abs(OutG.SiPredict./OutG.SiO));
% OutG.NaGuessError=abs(1-abs(OutG.NaPredict./OutG.Na));
OutG.SiGuessError=abs(OutG.SiPredict-OutG.SiO);
OutG.NaGuessError=abs(OutG.NaPredict-OutG.Na);
%% Chyba modelu - riziková místa
figure('position',[0 80 750 800]);
t=tiledlayout(2,1,'TileSpacing','compact','Padding','compact');



OutGi=rmmissing(OutG);
OutGii=OutGi(OutGi.SiGuessError>0 & OutGi.SiGuessError<inf & OutGi.NaGuessError<inf,:);

OutGi=OutGii(OutGii.Temperature>=24 & OutGii.Temperature<=26,:);




xt=OutGi.Viscosity;
yt=OutGi.Density;
zsit=OutGi.SiO;
znat=OutGi.Na;

zsig=OutGi.SiGuessError;

%
znag=OutGi.NaGuessError;
colorbar;
ax=[];
nexttile;
hold on;
ax(end+1)=gca;
% scatter3(xt,yt,zsit,'ob','filled');
scatter3(xt,yt,zsit,10,zsig,'o','filled');
xlabel('Viscosity');
ylabel('Density');
zlabel('SiO2');
cbar=colorbar;
cbar.Label.String='SiO_{2} (mol/l)';

title('SiO_{2} composition guess error (mol/l)');
nexttile;
hold on;
ax(end+1)=gca;
% scatter3(xt,yt,znat,'ob','filled');
scatter3(xt,yt,znat,10,znag,'o','filled');
xlabel('Viscosity');
ylabel('Density');
zlabel('Na');
cbar=colorbar;
cbar.Label.String='Na^{+} (mol/l)';
title('Na^{+} composition guess error (mol/l)');

set(ax,'ColorScale','log');

%% Histogram
figure;
t=tiledlayout(2,1,'TileSpacing','compact','Padding','compact');

nexttile;
hold on;
ax1=gca;

    xlabel('SiO_{2} composition guess error (mol/l)');
    xlim([0,2]);
legend;
nexttile;
hold on;

    xlabel('Na^{+} composition guess error (mol/l)');
    ylabel(t,'Count');
    xlim([0,2]);
legend;

ax2=gca;
temp=[15,20,25,30];
for i=1:numel(temp)
    idx=OutGii.Temperature>temp(i)-1 & OutGii.Temperature<temp(i)+1;

    [N,edges]=histcounts(OutGii.SiGuessError(idx) ,1000);

    plot(ax1,edges(1:end-1),N,'DisplayName',sprintf('Temperature=%d°C',temp(i)));
    
    
    [N,edges]=histcounts(OutGii.NaGuessError(idx),1000);
    plot(ax2,edges(1:end-1),N,'DisplayName',sprintf('Temperature=%d°C',temp(i)));

end
% set(gca,'XScale','log');




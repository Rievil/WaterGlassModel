
load('MatriceDensityViskozity.mat');
%
trange=[15,20.526315789473685,25.263157894736842,30];
%%
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
% print(fig,'Contour','-r300','-dpng');
%%
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
    scatter(zfinV,zfinD,[],zSI,'filled');
%     contourf(zfinV,zfinD,zSI,'ShowText','on');
    
    if tr==1
        title('SiO_{2} composition');
    end
    % ax.XAxis.Scale='log';
    % ax.YAxis.Scale='log';
    xlim([0 41]);
    ylim([1 2]);
    c=colorbar;
    c.Label.String=sprintf('SiO_{2} at %d °C (mol/l)',round(temp,0));
    %
%     fig=figure;
%     ax=gca;
    nexttile;
    scatter(zfinV,zfinD,[],zNA,'filled');
%     contourf(zfinV,zfinD,zNA,'ShowText','on');
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
print(fig,'Contour_Scatter','-r300','-dpng');
%%

%%
[X,Y]=meshgrid(unique(T.zv),unique(T.zd));
%%
contour(X,Y,B,'ShowText','on');
%%
scatter(T.zv,T.x);
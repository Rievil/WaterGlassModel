load('C:\Users\Richard\OneDrive - Vysoké učení technické v Brně\Měření\2021\WaterGlass\MatriceDensityViskozity.mat');
%%
temp=15;
T=OutT(OutT.t==temp,:);

%%
x = -2:0.2:2;
y = -2:0.2:3;
[X,Y] = meshgrid(x,y);
Z = X.*exp(-X.^2-Y.^2);
contour(X,Y,Z,'ShowText','on');
%%

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
%%
zfinV=cell2mat(arrV);
zfinD=cell2mat(arrD);
%%
fig=figure;
ax=gca;
contourf(zfinV,zfinD,zSI,'ShowText','on');
xlabel('Viscozity (Pa\cdots)');
ylabel('Density (g/cm^{3})');
% ax.XAxis.Scale='log';
% ax.YAxis.Scale='log';
title(sprintf('Water glass SiO_{2} composition at %d °C (mol/l)',temp));
%%
fig=figure;
ax=gca;
contourf(zfinV,zfinD,zNA,'ShowText','on');
xlabel('Viscozity (Pa\cdots)');
ylabel('Density (g/cm^{3})');
% ax.XAxis.Scale='log';
% ax.YAxis.Scale='log';
title(sprintf('Water glass Na^{+} composition at %d °C (mol/l)',temp));
%%

%%

%%
[X,Y]=meshgrid(unique(T.zv),unique(T.zd));
%%
contour(X,Y,B,'ShowText','on');
%%
scatter(T.zv,T.x);
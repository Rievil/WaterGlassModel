clear all;
filename=[cd '\Richardovi_souhrn dat.xlsx'];
T=readtable(filename,'sheet','First');
zz=T{2:end,2:end};
x=T{2:end,1};
y=T{1,2:end}';

xx=[];
for i=1:numel(y)
    xx=[xx, x];
end

yy=[];
for i=1:numel(x)
    yy=[yy, y];
end
yy=yy';

ressize=size(xx,1)*size(xx,2);

xxb=reshape(xx,[ressize,1]);
yyb=reshape(yy,[ressize,1]);
zzb=reshape(zz,[ressize,1]);

[xData, yData, zData] = prepareSurfaceData( xxb, yyb, zzb );

% Set up fittype and options.
ft = fittype( 'poly44' );
opts = fitoptions( 'Method', 'LinearLeastSquares' );
opts.Normalize = 'on';
opts.Robust = 'LAR';

% Fit model to data.
[fitresult, gof] = fit( [xData, yData], zData, ft, opts );


fig=figure('position',[0 80 800 600]);
hold on;
box on;
grid on;
ax=gca;

zzfit=fitresult(xx,yy);

s=surf(xx,yy,zzfit,'FaceAlpha',0.8);
s.EdgeColor='none';
shading interp;

scatter3(xxb,yyb,zzb,'Filled','dk');
formula=char(fitresult);
tit=title(sprintf([formula '\n R^{2}=%0.4f'],gof.rsquare));

view(-41,41);
legend('Interpolated area','Measured data','Location','best');
xlabel('Dry matter (%)');
ylabel('Silicate modulus');
zlabel('Density (g/cm^{3})');
set(ax,'FontName','Palatino linotype','FontSize',14,'LineWidth',0.8);
tit.FontSize=8;
plotname=[cd '\First'];
saveas(fig,plotname,'png');
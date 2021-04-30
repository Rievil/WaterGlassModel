clear all;
filename=[cd '\Richardovi_souhrn dat_upr.xlsx'];
T=readtable(filename,'sheet','Second');
x=T.x;
y=T.y;
z=T.z;
class=T.legend;

[xData, yData, zData] = prepareSurfaceData( x, y, z );

% Set up fittype and options.
ft = fittype( 'poly22' );
opts = fitoptions( 'Method', 'LinearLeastSquares' );
opts.Normalize = 'on';
opts.Robust = 'LAR';

% Fit model to data.
[fitresult, gof] = fit( [xData, yData], zData, ft, opts );

[xx,yy] = meshgrid(min(x):0.25:max(x),min(y):0.25:max(y));

fig=figure('position',[0 80 800 600]);
hold on;
box on;
grid on;
ax=gca;

zz=fitresult(xx,yy);

s=surf(xx,yy,zz,'FaceAlpha',0.8);
s.EdgeColor='none';
shading interp;

scatter3(x,y,z,[],class,'Filled','dk');
formula=char(fitresult);
title(sprintf([formula '\n R^{2}=%0.4f'],gof.rsquare));
view(-41,41);
legend('Interpolated area','Measured data','Location','best');
xlabel('Na^{+} (mol/l)');
ylabel('SiO_{2} (mol/l)');
zlabel('Density (g/cm^{3})');
set(ax,'FontName','Palatino linotype','FontSize',14,'LineWidth',0.8);
saveas(fig,[cd '\Second'],'png');
%%
Test=table(x,y,z);
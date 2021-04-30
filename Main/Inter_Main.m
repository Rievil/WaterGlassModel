cd('H:\Google drive\Škola\Mìøení\2021\Vlastik_Interpolace');
%% Create small data set for each x y z

%%
f = @(x,y) x.^3 + y.^3;

[xx,yy] = meshgrid(-5:0.25:5);

[fx,fy] = gradient(f(xx,yy),0.25);

x0 = 1;
y0 = 2;
t = (xx == x0) & (yy == y0);
indt = find(t);
fx0 = fx(indt);
fy0 = fy(indt);
% Create a function handle with the equation of the tangent plane z.

z = @(x,y) f(x0,y0) + fx0*(x-x0) + fy0*(y-y0);
% Plot the original function f(x,y), the point P, and a piece of plane z that is tangent to the function at P.

zz=f(xx,yy);

% zz=zz-min(zz);
%%

rowlength=size(xx,1);
newlength=rowlength*rowlength;

xb=reshape(xx,[newlength,1]);
yb=reshape(yy,[newlength,1]);
zb=reshape(zz,[newlength,1]);

% xb=xb-min(xb);
% yb=yb-min(yb);
% zb=zb-min(zb);
%%
fig=figure('position',[0 40 1500 650]);
subplot(1,2,1);
ax=gca;
hold on;
grid on;
box on;

xqu=4.032;
yqu=3.15;

xq=linspace(xqu,xqu,rowlength)';
yq=linspace(yqu,yqu,rowlength)';

xqline=linspace(min(xb),max(xb),rowlength)';
yqline=linspace(min(yb),max(yb),rowlength)';


[Xq,Yq,vq] = griddata(xb,yb,zb,xqu,yqu);
% scatter3(xb,yb,zb,'.');
s=surf(xx,yy,zz);
s.EdgeColor='none';

% lighting gouraud
shading interp;
plot3(Xq,Yq,vq,'-ok','MarkerFaceColor','k');

[Xq1,Yq1,vq1] = griddata(xb,yb,zb,xq,yqline);
[Xq2,Yq2,vq2] = griddata(xb,yb,zb,xqline,yq);

plot3(Xq1,Yq1,vq1,'-k');
plot3(Xq2,Yq2,vq2,'-k');

xlabel('Variable \it v_{1} \rm [unit]');
ylabel('Variable \it v_{2} \rm [unit]');
zlabel('Variable \it v_{3} \rm [unit]');

view(-41,28);

subplot(1,2,2);
hold on;
grid on;
box on;

scatter3(xb,yb,zb,'.');

view(-41,28);
[fitobj,gof] = fit([xb yb],zb,'poly33');
tst=char(fitobj)

title(ax,sprintf(['Rovnice plochy: ' tst '\n R^{2}=1.00']));
saveas(fig,[cd '\Example'],'png');
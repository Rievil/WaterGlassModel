T=GetData([cd '\Development\Vlastik_All Data.xlsx']);
%%

Ti=T(T.xlabidx=="Na+ (mol/kg)" & T.zlabidx=="Viscosity",:);
%%
Ti=Ti(:,[1,2,3,4,5,6,7,8,30]);
Ti=rmmissing(Ti);
x=Ti.x;
y=Ti.y;
z=Ti.z;
s=Ti.std;
s=s-min(s);
s=s/max(Ti.std);
s=s*80+10;
c=Ti.Teplota;

Tc=table(x,y,z,s,c,'VariableNames',{'X','Y','Z','Std','Temp'});
unqt=unique(Tc.Temp);
clrs=colormap(parula(numel(unqt)));
figure;
hold on;
for i=1:numel(unqt)
    Tci=Tc(Tc.Temp==unqt(i),:);

    xi=Tci.X;
    yi=Tci.Y;
    zi=Tci.Z;
    si=Tci.Std;
    ci=Tci.Temp;

%     scatter3(xi,yi,zi,si,ci,'Filled');   
    [fitresult, gof] = createFit1(xi, yi, zi);

    lx=linspace(min(xi),max(yi),10);
    ly=linspace(min(xi),max(yi),10);
    %                 scatter3(obj.MainAx,T.Source{i,1}.x,T.Source{i,1}.y,T.Source{i,1}.z,'marker','.');
    [xx,yy] = meshgrid(lx,ly);

    zz=fitresult(xx,yy);
%     plainname=sprintf('Mixture %s, T=%d',T.Source{i,1}.Mixture(1),T.Temp(i));
    plainname=sprintf("Temp %d °C R^{2}=%0.2f",unqt(i),gof.rsquare);
    surf(xx,yy,zz,'FaceAlpha',0.8,'DisplayName',plainname,'FaceColor',clrs(i,:));
end
xlabel('');
ylabel('');
legend;
set(gca,'ZScale','log');
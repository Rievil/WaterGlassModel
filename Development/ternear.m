%% Reading function
T=readtable("Ternear.csv",'VariableNamingRule','preserve');
T=T(:,["End X","End Y","Start X","Start Y","Layer"]);

obj=Cad2Line(T,"Layer");
%% Ploting function
fig=plot(obj);

%% Ternar 2 cartesian
a=0.7;
b=0.2;
c=1-a-b;

x=b+c/2;
y=tan(deg2rad(60))*c/2;

scatter(x,y,'o','filled');
%% Cartesian 2 ternar
ci=y/tan(deg2rad(60))*2;
bi=x-y/tan(deg2rad(60));
ai=1-c-b;
%%
data=readtable("data pro Vlastika_Šablona_2022-10-07.xlsx",'VariableNamingRule','preserve');
%
data.('x4Label')=string(data.('x4Label'));
data.('y4Label')=string(data.('y4Label'));
data.('veličina')=string(data.('veličina'));
T=data(data.('x4Label')=='Na+ (mol/kg)' & data.('y4Label')=='Si4+ (mol/kg)' & data.('veličina')=='Viscosity',...
    ["Na2O_proc","SiO2_proc","H2O_proc","hodnota veličiny","veličina","Teplota","legend_proc"]);
T.("Na2O_proc")=T.("Na2O_proc")/100;
T.("SiO2_proc")=T.("SiO2_proc")/100;
T.("H2O_proc")=T.("H2O_proc")/100;

%

a=T.("Na2O_proc");
b=T.("SiO2_proc");
c=T.("H2O_proc");
z=T.("hodnota veličiny");

xtr=b+c/2;
ytr=tan(deg2rad(60))*c/2;
%%
obj.AddPoints(x,y);
%%

fig=plot(obj);
%%
SaveMyFig(fig,'Trenar_PointsDistribution');
% scatter(x,y,30,'o','filled');
%% Surface functional
figure;
hold on;
axis equal;

height=tan(deg2rad(60))*0.5;
xt=[0,0.5,1,0];
yt=[0,height,0,0];

xg=linspace(0,1,250);
yg=linspace(0,height,250);

[X,Y]=meshgrid(xg,yg);

[in]=inpolygon(X,Y,xt,yt);


zg=zeros(250,250);
zi=griddata(xtr,ytr,z,X,Y);

plot(xt,yt,'-k','LineWidth',3);
tri=delaunay(xtr,ytr);

trisurf(tri,xtr,ytr,z);

shading interp
xlabel('x');
ylabel('y');

view(0,90);
xlim([0,1]);
ylim([0,height]);
%%
figure;
% xt=[0,0.5,1,0]*250;
% yt=[0,height,0,0]*250;
sizeImg=1000;
xt=obj.ShapeList{1, 10}.Cordinates.x*sizeImg;
yt=obj.ShapeList{1, 10}.Cordinates.y*sizeImg;

pgon=polyshape(xt,yt);
% plot(pgon);
BW1 = poly2mask(xt,yt,sizeImg,sizeImg);
imshow(BW1);
BW2 = bwskel(BW1);
montage({BW1,BW2},'BackgroundColor','blue','BorderSize',5)
% spiralVolLogical = imbinarize( bwboundaries(pgon));
%%
mask=BW1;
bp = bwmorph(mask, 'branchpoints');
mask(bp) = false; % Erase branchpoints.
[labeledImage, numRegions] = bwlabel(mask);
for k = 1 : numRegions
    thisRegion = ismember(labeledImage, k);
    endpoints = bwmorph(thisRegion, 'endpoints');
    % Get coordinate
    [r, c] = find(endpoints);
    euclideanDistance(k) = sqrt((r(end)-r(1)).^2 + (c(end)-c(1)).^2);
    area(k) = sum(thisRegion);
    tortuosity(k) = area(k) / euclideanDistance(k);
end
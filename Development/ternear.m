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
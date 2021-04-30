%% When new measuremnts are added to 'Data pro MATLAB.xlsx' run this script
[R]=ProcessInputRawData;
%% Load Process data
load('MT_VDTable.mat');
%% Fit New data and store fit objects
[FitTable]=CreateFitObj(R);
%% Load fit objects with source data
load('FitObj.mat');
%%
obj=FitGuide;
obj.Load;
%%
DC=DataCarusel(R,[8,7]);
accuracy=[];
sel={[1 2 3 4],[5 6 7 8],[9 10 11 12]};
charfit=[];
coerfit=[];
fitall=[];
fitall=struct;
for n=1:3
    fig=figure('Position',[93,47,1574,798]);
    ax=gca;
    hold on;
    grid on;
    box on;
    k=0;
    for i=sel{n} %1:DC.RealCombCount
        k=k+1;

        [Tf,B]=GetCombinations(DC,i);
        fitall(n).Mixture(k).Temp=Tf.T(1);
        fitall(n).Name=Tf.Mixture(1);
        
        x=Tf.x;
        y=Tf.y;
        zout=Tf.z;

        datalabel=sprintf(['M: %s | T: %0.2f �C'],Tf.Mixture(1),Tf.T(1));
        [s,fitresult,gof]=MyFit(ax,x,y,zout,datalabel,DC.RealCombCount);
        fitall(n).Mixture(k).Fit=fitresult;
%         fitall{n,i}=fitresult;
        charfit=[charfit; char(fitresult)];
        accuracy=[accuracy; gof.rsquare];
        coerfit=[coerfit; coeffvalues(fitresult)];
    end
    
    if Tf.ZType=="v"
        zlabel('Viscosity (Pa\cdots)');
    else
        zlabel('Density (g/cm^{3})');
    end
    
    xlabel('Na^{+} (mol/l)');
    ylabel('SiO_{2} (mol/l)');
%     zlabel('Density (g/cm^{3})');
    title(sprintf('Mixture: %s',Tf.Mixture(1)));
    view(19,16);
    legend('location','best');
    set(ax,'LineWidth',1.2,'FontName','Palatino linotype');
%     ax.ZScale='log';
    fig.GraphicsSmoothing = 'on';
%     saveas(fig,[cd '\MultiInter_' char(num2str(n))],'png');
%     imwrite(fig, [cd '\MultiInter_' char(num2str(n))], 'Resolution', 300)
end
%%
% Na + = 3,316 mol/l, SiO2 = 0 mol/l
% Na+ = 3,304 mol/l, SiO2 = 0,1652 mol/l
% Na+ = 3,291 mol/l, SiO2 = 0,4114 mol/l
% Na+ = 3,268 mol/l, SiO2 = 0,8171 mol/l


xna=[3.316,3.304,3.291,3.268]';
ysio=[0,0.1652,0.4114,0.8171]';
xnab=[];
ysiob=[];
zout=[];
ztemp=[];
for b=1:1:4
    fitobj=fitall(3).Mixture(b).Fit;
    zout=[zout; fitobj(xna,ysio)];
    ztemp=[ztemp; fitall(3).Mixture(b).Temp; fitall(3).Mixture(b).Temp; fitall(3).Mixture(b).Temp; fitall(3).Mixture(b).Temp];
    xnab=[xnab;xna];
    ysiob=[ysiob;ysio];
end
%%
out=table(xnab,ysiob,ztemp,zout,'VariableNames',{'Na+','SiO2','Temp','InterDensity'});
writetable(out,'NaOH-NaVS_h_InterpolaceProVlastika.xlsx');
%%
Tcharparam=table(charfit,coerfit,'VariableNames',{'Equation','Coefficients'});
Tcharparam=[table(sheets','Variablenames',{'SourceSheets'}) ,Tcharparam];
writetable(Tcharparam,'Param.xlsx','Sheet','Equation');
%%
x=[1 2 3];
y=[1 2 3];
zout=[1 2 3];
plot3(x,y,zout);
%%
acmean=mean(accuracy);
err=2/3*std(accuracy)/power(11,1/2);
res=sprintf('Mean accuracy: %0.4f \x00B1 %0.4f',acmean,err);
%%
FiT=struct;
c=0;
for type=["d","v"]
TD=R(R.ZType==type,:);
unqT=unique(TD.T);

    for i=1:numel(unqT)
        TDT=TD(TD.T==unqT(i),:);
        [fitresult,gof]=FitProcessedData(TDT.x,TDT.y,TDT.z);
        
        c=c+1;
        FiT(c).Fit=fitresult;
        FiT(c).Gof=gof;
        FiT(c).Type=type; 
        FiT(c).Temp=unqT(i); 
        FiT(c).Source=TDT; 
    end
end

FitTable=struct2table(FiT);

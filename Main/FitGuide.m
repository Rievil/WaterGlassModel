classdef FitGuide < handle

    
    properties
        Filename;
        RawInputData;
        FitTable;
        CurrType;
    end
    
    properties
        MainAx;
        SupAx;
        MainPlain;
        MainLine;
        SupInterLine;
        SupLine;
        GX;
        GY;
        GT;
        FinY;
        FinYGof;
        LimX;
        LimY;
        LimZ;
    end
    
    methods
        function obj = FitGuide(~)
            obj.Filename='data pro MATLAB.xlsx';
            obj.CurrType="v";
        end
        
        function Load(obj)
            load('MT_VDTable.mat');
            obj.RawInputData=R;
            
            load('FitObj.mat');
            obj.FitTable=FitTable;
        end
        
        function Run(obj)
            warning ('off','all');
            ProcessInputRawData(obj);
            CreateFitObj(obj);
            warning ('on','all');
        end
        
        function SetType(obj,type)
            obj.CurrType=type;
        end
        
        function R=GetData(obj)
            
            R=obj.ProcessInputRawData;
            CreateFitObj(obj);
        end
        
        function AssAxis(obj,MainAx,SupAx)
            obj.MainAx=MainAx;
            obj.SupAx=SupAx;
        end
        
        function [Z,gof]=GetZ(obj,x,y,t,type)
            obj.GX=x;
            obj.GY=y;
            obj.GT=t;
            
            T=obj.FitTable(obj.FitTable.Type==type,:);
            temp=[];
            zval=[];
            
            for i=1:size(T,1)
                zval=[zval; T.Fit{i}(x,y)];
                temp=[temp; T.Temp(i)];
            end
            
            xt=temp;
            yt=zval;

            [fitresult,gof]=FitGuide.FitLine(xt,yt);
            Z=fitresult(t);
        end
        
        function InterDraw(obj,x,y,t)
            obj.GX=x;
            obj.GY=y;
            obj.GT=t;
            
            cla(obj.SupAx);
            ax=obj.SupAx;
            
            cla(ax);
            hold(ax,'on');
            grid(ax,'on');
            T=obj.FitTable(obj.FitTable.Type==obj.CurrType,:);
            temp=[];
            zval=[];
            
            for i=1:size(T,1)
                zval=[zval; T.Fit{i}(x,y)];
                temp=[temp; T.Temp(i)];
            end
            
            xt=temp;
            yt=zval;
            

            
            [fitresult,fingof]=FitGuide.FitLine(xt,yt);
            
            newx=linspace(min(xt),max(xt),20)';
            newy=fitresult(newx);
            
            xlim(ax,[min(xt),max(xt)]);
            xlabel(ax,'Temperature T (°C)');
            
            plot(ax,newx,newy,'-r','DisplayName','Fit');
            plot(ax,xt,yt,'or','DisplayName','Data','MarkerFaceColor','r');
            
            finy=fitresult(t);
            
            if obj.CurrType=="v"
                ylabel(ax,'Viscosity (pa\cdots)');
                finlabel=sprintf('Guess viscosity,R^{2}=%0.4f',fingof.rsquare);
            else
                ylabel(ax,'Density D (kg/m^{3})');
                finlabel=sprintf('Guess density,R^{2}=%0.4f',fingof.rsquare);
            end
            
            plot(ax,t,finy,'+k','MarkerSize',10,'DisplayName',finlabel,'MarkerFaceColor','k','LineWidth',1.5);
            
            
            obj.FinY=finy;
            obj.FinYGof=fingof;
            lgd=legend(ax,'location','southoutside');
            lgd.NumColumns=3;
            
            ShowPointInMain(obj);
        end
        
        function Draw(obj)
            cla(obj.MainAx);
            cla(obj.SupAx);
            
            obj.LimX=[];
            obj.LimY=[];
            obj.LimZ=[];
            
            for i=1:numel(obj.MainLine)
                delete(obj.MainLine{i});
            end
            obj.MainLine=[];
            
            hold( obj.MainAx, 'on' );
            hold( obj.SupAx, 'on' );
            box( obj.MainAx,'on');
            grid( obj.MainAx,'on');
            
            T=obj.FitTable(obj.FitTable.Type==obj.CurrType,:);
            clrs=colormap(obj.MainAx,parula(size(T,1)));
            
            for i=1:size(T,1)
                lx=linspace(min(T.Source{i,1}.x),max(T.Source{i,1}.x),10);
                ly=linspace(min(T.Source{i,1}.y),max(T.Source{i,1}.y),10);

                [xx,yy] = meshgrid(lx,ly);

                c=clrs(i,:);

                zz=T.Fit{i,1}(xx,yy);
                plainname=sprintf('Mixture %s, T=%d',T.Source{i,1}.Mixture(1),T.Temp(i));
                obj.MainPlain{i}=surf(obj.MainAx,xx,yy,zz,'FaceAlpha',0.8,'DisplayName',plainname,'FaceColor',c);
                Limits(obj,xx,yy,zz);
            end
            legend(obj.MainAx);
            xlabel(obj.MainAx,'Na^{+} (mol/l)');
            ylabel(obj.MainAx,'SiO_{2} (mol/l)');
            
            if obj.CurrType=="v"
                zlabel(obj.MainAx,'Viscosity (Pa\cdots)');
                title(obj.MainAx,'Viscosity interpolation');
            else
                zlabel(obj.MainAx,'Density (g/cm^{3})');
                title(obj.MainAx,'Density interpolation');
            end
            
            view( obj.MainAx,[45,45]);
            xlim(obj.MainAx,obj.LimX);
            ylim(obj.MainAx,obj.LimY);
            zlim(obj.MainAx,obj.LimZ);
        end
        

        
    end
    
    methods (Access=private)
        function [R]=ProcessInputRawData(obj)
%             file=which(class(obj));
            filename=[char(replace(which(class(obj)),[class(obj) '.m'],'')), obj.Filename];
            
%             filename=obj.Filename;
            
            sheets={'NaOH-NaVS_h_15C','NaOH-NaVS_h_20C','NaOH-NaVS_h_25C','NaOH-NaVS_h_30C','KOH-KVS_h_15C','KOH-KVS_h_20C',...
                'KOH-KVS_h_25C','KOH-KVS_h_30C','KOH-KVS_v_15C','KOH-KVS_v_20C','KOH-KVS_v_25C','KOH-KVS_v_30C'};
            temp=[15,20,25,30,15,20,25,30,15,20,25,30];
            mixture={'NaOH-NaVS_h','NaOH-NaVS_h','NaOH-NaVS_h','NaOH-NaVS_h','KOH-KVS_h','KOH-KVS_h','KOH-KVS_h','KOH-KVS_h',...
                'KOH-KVS_v','KOH-KVS_v','KOH-KVS_v','KOH-KVS_v',};

            ztype={'d','d','d','d','d','d','d','d','v','v','v','v',};

            Tout=table;
            i=0;
            for name=sheets
                i=i+1;

                T=readtable(filename,'Sheet',string(name));
                S=strings([size(T,1),1]);
                S(:,1)=name;

                M=strings([size(T,1),1]);
                M(:,1)=string(mixture{i});

                Ztype=strings([size(T,1),1]);
                Ztype(:,1)=string(ztype{i});


                ID=zeros([size(T,1),1]);
                ID(:,1)=i;

                Temp=zeros([size(T,1),1]);
                Temp(:,1)=temp(i);

                Tout=[Tout; T, table(S,M,Temp,Ztype,ID,'VariableNames',{'Sheet','Mixture','Temperature','ZType','ID'})];
                clear ID;
            end

            TV=Tout(Tout.ZType=="v",:);
            density=table(TV.z,'VariableNames',{'Viscosity'});
            viscosity=table(nan(size(density,1),1),'VariableNames',{'Density'});
            TV=[TV, density, viscosity];

            clear density vyscosity;
            TD=Tout(Tout.ZType=="d",:);
            density=table(TD.z,'VariableNames',{'Density'});
            viscosity=table(nan(size(density,1),1),'VariableNames',{'Viscosity'});
            TD=[TD, density, viscosity];

            Tout2=[TV; TD];

            Tout2.Properties.VariableDescriptions{'x'}='Na^{+}';
            Tout2.Properties.VariableDescriptions{'y'}='SiO_{2}';

            R=table(Tout2.x,Tout2.y,Tout2.z,Tout2.Density,Tout2.Viscosity,Tout2.std,Tout2.legend,Tout2.Temperature,Tout2.Mixture,Tout2.ZType,...
                'VariableNames',{'x','y','z','D','V','std','legend','T','Mixture','ZType'});
            R.Properties.VariableDescriptions={'Na^{+}','SiO_{2}','Density/Viscosity','Density','Viscosity','standard deviation','data set','Temperature','Source mixture','Type of z variable'};
            R.Properties.VariableUnits={'mol/l','mol/l','','kg/m^{3}','Pa\cdots','-','','°C','',''};
            
            obj.RawInputData=R;
            
            save('MT_VDTable.mat','R');
        end
        
        function [FitTable]=CreateFitObj(obj)
            R=obj.RawInputData;
            FiT=struct;
            c=0;
            for type=["d","v"]
            TD=R(R.ZType==type,:);
            unqT=unique(TD.T);

                for i=1:numel(unqT)
                    TDT=TD(TD.T==unqT(i),:);
                    [fitresult,gof]=FitGuide.FitProcessedData(TDT.x,TDT.y,TDT.z);

                    c=c+1;
                    FiT(c).Fit=fitresult;
                    FiT(c).Gof=gof;
                    FiT(c).Accuracy=gof.rsquare;
                    FiT(c).Type=type; 
                    FiT(c).Temp=unqT(i); 
                    FiT(c).Source=TDT; 
                end
            end

            FitTable=struct2table(FiT);
            obj.FitTable=FitTable;
            save('FitObj.mat','FitTable');
        end
        
        function ShowPointInMain(obj)
            ax=obj.MainAx;
            xline=linspace(ax.XLim(1),ax.XLim(2),10)';
            yline=linspace(ax.YLim(1),ax.YLim(2),10)';
            zline=linspace(ax.ZLim(1),ax.ZLim(2),10)';
            
            xs=linspace(obj.GX,obj.GX,10)';
            ys=linspace(obj.GY,obj.GY,10)';
            zs=linspace(obj.FinY,obj.FinY,10)';
            
            if numel(obj.MainLine)>0
                obj.MainLine{1}.XData=xline;
                obj.MainLine{1}.YData=ys;
                obj.MainLine{1}.ZData=zs;
                
                obj.MainLine{2}.XData=xs;
                obj.MainLine{2}.YData=yline;
                obj.MainLine{2}.ZData=zs;
                
                obj.MainLine{3}.XData=xs;
                obj.MainLine{3}.YData=ys;
                obj.MainLine{3}.ZData=zline;
            else
                obj.MainLine{1}=plot3(ax,xline,ys,zs,'Color','r','HandleVisibility','off');
                obj.MainLine{2}=plot3(ax,xs,yline,zs,'Color','g','HandleVisibility','off');
                obj.MainLine{3}=plot3(ax,xs,ys,zline,'Color','b','HandleVisibility','off');
            end
        end
        function Limits(obj,xx,yy,zz)
            xlimits=[obj.LimX;min(min(xx)),max(max(xx))];
            obj.LimX=[min(xlimits(:,1)),max(xlimits(:,2))];
            
            ylimits=[obj.LimY;min(min(yy)),max(max(yy))];
            obj.LimY=[min(ylimits(:,1)),max(ylimits(:,2))];
            
            zlimits=[obj.LimZ;min(min(zz)),max(max(zz))];
            obj.LimZ=[min(zlimits(:,1)),max(zlimits(:,2))];
        end
    end
    
    methods (Static)
        function [fitresult,gof]=FitProcessedData(x,y,z)
    
            [xData, yData, zData] = prepareSurfaceData( x, y, z );

            % Set up fittype and options.
            ft = fittype( 'poly22' );
            opts = fitoptions( 'Method', 'LinearLeastSquares' );
            opts.Normalize = 'on';
            opts.Robust = 'LAR';

            % Fit model to data.
            [fitresult, gof] = fit( [xData, yData], zData, ft, opts );
        end
        
        function [fitresult,gof]=FitLine(x,y)
            ft = fittype( 'poly2' );
            opts = fitoptions( 'Method', 'LinearLeastSquares' );
            opts.Normalize = 'on';
            opts.Robust = 'LAR';

            % Fit model to data.
            [fitresult, gof] = fit( x,y,ft, opts );
        end
    end
end


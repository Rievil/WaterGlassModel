classdef WGInterp < handle
    properties
        Data;
        tCol;
        xLab;
        yLab;
        zLab;
        FitT;
        Parent;
        xLog=false;
        yLog=false;
        zLog=true;
        XPSet=0;
        YPSet=0;
        TPSet=0;
        IFitT;
        ZFit;
        ZFitGof;
        ZFitResult=0;
        Lims;
        TarHandle;
    end

    methods
        function obj=WGInterp(parent)
            obj.Parent=parent;
%             obj.PlotPanel=obj.Parent.PlotPanel;
        end

        function SetData(obj,data,xlab,ylab,zlab,tcol)
            obj.Data=data;
            obj.xLab=xlab;
            obj.yLab=ylab;
            obj.zLab=zlab;
            obj.tCol=tcol;
            Fit(obj);
        end

        

        function Fit(obj)
            unqt=unique(obj.Data.T);
            col=lines(numel(unqt));
            obj.FitT=table;
            for i=1:numel(unqt)
                Tmi=obj.Data(obj.Data.T==unqt(i),:);
                [fitresult,gof]=WGInterp.FitProcessedData2(Tmi.x,Tmi.y,Tmi.z);
                
                x1=Tmi.x;
                y1=Tmi.y;
                z1=Tmi.z;
            
                lx=linspace(min(x1),max(x1),10);
                ly=linspace(min(y1),max(y1),10);

                [xx,yy] = meshgrid(lx,ly);
                zz=fitresult(xx,yy);
                obj.FitT=[obj.FitT; table({xx},{yy},{zz},{fitresult},{gof},unqt(i),{col(i,:)},'VariableNames',...
                    {'x','y','z','fit','gof','T','col'})];
            end
        end
        
        function SetFitParams(obj,x,y,t)
            obj.XPSet=x;
            obj.YPSet=y;
            obj.TPSet=t;
        end

        function GetFitResult(obj)
            xt=obj.FitT.T;
            zresult=zeros(size(obj.FitT,1),1);
            for i=1:size(obj.FitT,1)
                fitobj=obj.FitT.fit{i};
                zresult(i,1)=fitobj(obj.XPSet,obj.YPSet);
            end

            [fitobjfin,gof]=fit(xt,zresult,'poly3');
            obj.ZFit=fitobjfin;
            obj.ZFitGof=gof;
            obj.IFitT=table(xt,zresult,'VariableNames',{'T','Z'});

            obj.ZFitResult=obj.ZFit(obj.TPSet);
            obj.Parent.ResultField.Value=obj.ZFitResult;
        end

        function plotInter(obj)
            GetFitResult(obj);
            ax=obj.Parent.UIAxInt;
            cla(ax);
            hold(ax,'on');
            grid(ax,'on');
            scatter(ax,obj.IFitT.T,obj.IFitT.Z,60,'or','filled');

            xnew=linspace(obj.IFitT.T(1),obj.IFitT.T(end),100)';
            ynew=obj.ZFit(xnew);
            plot(ax,xnew,ynew,'-r');
            scatter(ax,obj.TPSet,obj.ZFitResult,60,'+k');
            ShowPoint(obj);
            xlim(ax,[min(xnew),max(xnew)]);
            ylim(ax,[min(obj.IFitT.Z)*0.9,max(obj.IFitT.Z)*1.1]);
        end

        function plot(obj)
            ax=obj.Parent.UIAx;
            cla(ax);
            obj.TarHandle=[];
            hold(ax,'on');
            grid(ax,'on');
            
            if obj.xLog
                set(ax,'XScale','log');
            else
                set(ax,'XScale','lin');
            end

            if obj.yLog
                set(ax,'YScale','log');
            else
                set(ax,'YScale','lin');
            end

            if obj.zLog
                set(ax,'ZScale','log');
            else
                set(ax,'ZScale','lin');
            end

            han=[];
            xlims=[inf,0];
            ylims=[inf,0];
            zlims=[inf,0];
            for i=1:size(obj.FitT,1)
                x=obj.FitT.x{i};
                y=obj.FitT.y{i};
                z=obj.FitT.z{i};
                T=obj.Data(obj.Data.T==obj.FitT.T(i),:);
                [xlims,ylims,zlims]=CheckLims(obj,x,y,z,xlims,ylims,zlims);
                scatter3(ax,T.x,T.y,T.z,60,'marker','o','MarkerFaceColor', ...
                    obj.FitT.col{i},'MarkerEdgeColor','k');
                han(end+1)=surf(ax,x,y,z,'FaceAlpha',0.8,'DisplayName', ...
                    sprintf("R2:%0.2f T:%d",obj.FitT.gof{i}.rsquare,obj.FitT.T(i)), ...
                    'FaceColor',obj.FitT.col{i});
                

                
            end
            xlabel(ax,sprintf("x: %s",obj.xLab));
            ylabel(ax,sprintf("y: %s",obj.yLab));
            zlabel(ax,sprintf("z: %s",obj.zLab));
            legend(ax,han,'Location','northeast','AutoUpdate','off');

            xlim(ax,xlims);
            ylim(ax,ylims);
            zlim(ax,zlims);

            obj.Lims=table(xlims',ylims',zlims','VariableNames',{'x','y','z'},'RowNames',{'Min','Max'});
        end

        function ShowPoint(obj)
            ax=obj.Parent.UIAx;

            x1=linspace(obj.XPSet,obj.XPSet,10)';
            y1=linspace(obj.YPSet,obj.YPSet,10)';
            z1=linspace(obj.Lims.z(1),obj.Lims.z(2),10)';

            x2=linspace(obj.XPSet,obj.XPSet,10)';
            y2=linspace(obj.Lims.y(1),obj.Lims.y(2),10)';
            z2=linspace(obj.ZFitResult,obj.ZFitResult,10)';
            
            x3=linspace(obj.Lims.x(1),obj.Lims.x(2),10)';
            y3=linspace(obj.YPSet,obj.YPSet,10)';
            z3=linspace(obj.ZFitResult,obj.ZFitResult,10)';
            if isempty(obj.TarHandle)
                h1=plot3(ax,x1,y1,z1,'r-','LineWidth',2);
                h2=plot3(ax,x2,y2,z2,'g-','LineWidth',2);
                h3=plot3(ax,x3,y3,z3,'b-','LineWidth',2);
                obj.TarHandle={h1,h2,h3};
            else
                set(obj.TarHandle{1},'XData',x1,'YData',y1,'ZData',z1);
                set(obj.TarHandle{2},'XData',x2,'YData',y2,'ZData',z2);
                set(obj.TarHandle{3},'XData',x3,'YData',y3,'ZData',z3);
            end

        end

        function [xlims,ylims,zlims]=CheckLims(obj,x,y,z,xlims,ylims,zlims)
            if xlims(1)>min(x,[],'all')
                xlims(1)=min(x,[],'all')*0.9;
            end

            if xlims(2)<max(x,[],'all')
                xlims(2)=max(x,[],'all')*1.1;
            end

            if ylims(1)>min(y,[],'all')
                ylims(1)=min(y,[],'all')*0.9;
            end
            
            if ylims(2)<max(y,[],'all')
                ylims(2)=max(y,[],'all')*1.1;
            end

            if zlims(1)>min(z,[],'all')
                zlims(1)=min(z,[],'all')*0.9;
            end
            
            if zlims(2)<max(z,[],'all')
                zlims(2)=max(z,[],'all')*1.1;
            end
        end
    end

    methods (Static)
        function [fitresult,gof]=FitProcessedData2(x,y,z)
            [xData, yData, zData] = prepareSurfaceData( x, y, z );
            
            % Set up fittype and options.
            ft = 'thinplateinterp';
            [fitresult, gof] = fit( [xData, yData], zData, ft, 'Normalize', 'on' );
        end
    end
end
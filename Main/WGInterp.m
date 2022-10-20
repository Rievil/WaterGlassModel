classdef WGInterp < handle
    properties
        Data;
        tCol;
        xLab;
        yLab;
        zLab;
        FitT;
        Parent;
    end

    methods
        function obj=WGInterp(parent)
            obj.Parent=parent;
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
            unqt=unique(obj.Data.(obj.tCol));
            col=lines(numel(unqt));
            obj.FitT=table;
            for i=1:numel(unqt)
                Tmi=obj.Data(obj.Data.(obj.tCol)==unqt(i),:);
                [fitresult,gof]=WGInterp.FitProcessedData2(Tmi.(obj.xLab),Tmi.(obj.yLab),Tmi.(obj.zLab));
                
                x1=Tmi.(obj.xLab);
                y1=Tmi.(obj.yLab);
                z1=Tmi.(obj.zLab);
            
                lx=linspace(min(x1),max(x1),10);
                ly=linspace(min(y1),max(y1),10);

                [xx,yy] = meshgrid(lx,ly);
                zz=fitresult(xx,yy);
                obj.FitT=[obj.FitT; table({xx},{yy},{zz},{fitresult},{gof},unqt(i),{col(i,:)},'VariableNames',...
                    {'x','y','z','fit','gof','T','col'})];
            end
        end

        function plot(obj)
            cla(obj.Parent.UIAx);
            han=[];
            for i=1:size(obj.FitT,1)
                x=obj.FitT.x{i};
                y=obj.FitT.y{i};
                z=obj.FitT.z{i};
                T=obj.Data(obj.Data.(obj.tCol)==obj.FitT.T(i),:);
                
                scatter3(obj.Parent.UIAx,T.(obj.xLab),T.(obj.yLab),T.(obj.zLab),60,'marker','o','MarkerFaceColor',obj.FitT.col{i},'MarkerEdgeColor','none');
                han(end+1)=surf(obj.Parent.UIAx,x,y,z,'FaceAlpha',0.8,'DisplayName',sprintf("R2:%0.2f T:%d",obj.FitT.gof{i}.rsquare,obj.FitT.T(i)),'FaceColor',obj.FitT.col{i});
            end
            legend(obj.Parent.UIAx,han);
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
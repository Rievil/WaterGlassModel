function [s,fitresult,gof]=MyFit_Lions(ax,x,y,z,displayname,count)
    
    [xData, yData, zData] = prepareSurfaceData( x, y, z );

    % Set up fittype and options.
    ft = fittype( 'poly22' );
    opts = fitoptions( 'Method', 'linearinterp' );
    opts.Normalize = 'off';
%     opts.Robust = 'LAR';

    % Fit model to data.
    [fitresult, gof] = fit( [xData, yData], zData, ft, opts );
    
    lx=linspace(min(x),max(x),10);
    ly=linspace(min(y),max(y),10);
    
%     [xx,yy] = meshgrid(min(x):0.25:max(x),min(y):0.25:max(y));
    [xx,yy] = meshgrid(lx,ly);

%     fig=figure('position',[0 80 800 600]);
%     hold on;
%     box on;
%     grid on;
%     ax=gca;
    clrs=colormap(colorcube(count));
    if numel(ax.Children)==0
        c=clrs(1,:);
    else
        c=clrs(numel(ax.Children)+1,:);
    end
    zz=fitresult(xx,yy);

    
    s=surf(ax,xx,yy,zz,'FaceAlpha',0.8,'DisplayName',displayname,'FaceColor',c);
%     figure;
%     h = plot(fitresult, [xData, yData], zData);
%     s=surf(ax,xx,yy,zz,'DisplayName',displayname,'FaceColor',c);
%     s.EdgeColor='none';
%     shading interp;
end
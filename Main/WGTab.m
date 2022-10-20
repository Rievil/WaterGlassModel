classdef WGTab < handle
    properties
        Parent;
        Panel;
        Tab;
        WGInterp;
        ID;
        UIAx;
        WGGuide;
        SSystem;
        IntType;
        SParam;
    end

    methods
        function obj=WGTab(parent,tabgroup,id)
            obj.Parent=parent;
            
            obj.WGGuide=obj.Parent.WGGuide;
            obj.WGInterp=WGInterp(obj);
            obj.ID=id;
%             obj.Panel=panel;

            ntab = uitab(tabgroup,'Title',num2str(id),'ButtonDownFcn',@obj.SetCurrent,'UserData',obj.ID);
            obj.Tab=ntab;

            DrawGUI(obj);
        end

        function delete(obj)
            ClearCont(obj,obj.Tab);
            obj.Tab.delete;
            delete(obj.WGInterp);
            obj.Parent=[];
        end

        function DrawGUI(obj)
            %Panel
%             ClearCont(obj,obj.Panel);
            g1 = uigridlayout(obj.Tab);
            g1.RowHeight = {'1x'};
            g1.ColumnWidth = {500,'1x'};

            uip1=uipanel(g1,'Title','Options');
            uip1.Layout.Row=1;
            uip1.Layout.Column=1;
            
            g2 = uigridlayout(uip1);
            g2.RowHeight = {30,30,30,30,30,'1x'};
            g2.ColumnWidth = {100,'1x'};
            
            edf1=uieditfield(g2,'Value',sprintf("%d",obj.ID),'Editable','on');
            edf1.Layout.Row=1;
            edf1.Layout.Column=2;

            tx1=uilabel(g2,'Text','Name:');
            tx1.Layout.Row=1;
            tx1.Layout.Column=1;

            cbox1=uidropdown(g2,"Items",obj.WGGuide.Param,"ItemsData",1:numel(obj.WGGuide.Param),...
                'ValueChangedFcn',@obj.CParamSel);
            obj.SParam=cbox1.Items{cbox1.Value};
            cbox1.Layout.Row=2;
            cbox1.Layout.Column=2;

            tx1=uilabel(g2,'Text','Parameter:');
            tx1.Layout.Row=2;
            tx1.Layout.Column=1;

            cbox2=uidropdown(g2,"Items",obj.WGGuide.System,"ItemsData",1:numel(obj.WGGuide.System),...
                'ValueChangedFcn',@obj.CSystemSel);
            obj.SSystem=cbox2.Items{cbox2.Value};
            cbox2.Layout.Row=3;
            cbox2.Layout.Column=2;

            tx1=uilabel(g2,'Text','System:');
            tx1.Layout.Row=3;
            tx1.Layout.Column=1;

            cbox3=uidropdown(g2,"Items",["x","x2","x3","x4","proc"],"ItemsData",1:5,...
                'ValueChangedFcn',@obj.CIntType);
            obj.IntType=cbox3.Items{cbox3.Value};
            cbox3.Layout.Row=4;
            cbox3.Layout.Column=2;

            tx1=uilabel(g2,'Text','InterpretationType:');
            tx1.Layout.Row=4;
            tx1.Layout.Column=1;
            
            uib1=uibutton(g2,'Text','Draw','ButtonPushedFcn',@obj.DrawPlot);
            uib1.Layout.Row=5;
            uib1.Layout.Column=[1 2];

            %%
            uip2=uipanel(g1,'Title','Plot');
            uip2.Layout.Row=1;
            uip2.Layout.Column=2;
            
            g3 = uigridlayout(uip2);
            g3.RowHeight = {'3x','1x'};
            g3.ColumnWidth = {'1x'};
            uiax=uiaxes(g3);
            uiax.Layout.Row=1;
            uiax.Layout.Column=1;
            obj.UIAx=uiax;
            hold(uiax,'on');
            set(uiax,'ZScale','log');
            view(uiax,30,30);
            uip3=uipanel(g3,'Title','Settings');
            uip3.Layout.Row=2;
            uip3.Layout.Column=1;
        end
        
        function CSystemSel(obj,src,evnt)
            obj.SSystem=src.Items{src.Value};
        end

        function CIntType(obj,src,evnt)
            obj.IntType=src.Items{src.Value};
        end

        function CParamSel(obj,src,evnt)
            obj.SParam=src.Items{src.Value};
        end

        function DrawPlot(obj,src,evnt)
            T=obj.WGGuide.FData(obj.WGGuide.FData.('Systém')==obj.SSystem & obj.WGGuide.FData.('zlabel')==obj.SParam,:);
            switch obj.IntType
                case "x"
                    xl="x";
                    yl="y";
                    zl="z";
                case "x1"
                    xl="x1";
                    yl="y1";
                    zl="z1";
                case "x2"
                    xl="x2";
                    yl="y2";
                    zl="z2";
                case "x3"
                    xl="x3";
                    yl="y3";
                    zl="z3";
                case "x4"
                    xl="x4";
                    yl="y4";
                    zl="z4";
                case "proc"
            end
               
            obj.WGInterp.SetData(T.FilteredTable{1},xl,yl,zl,'Teplota');
            
            plot(obj.WGInterp);
        end

        function ClearCont(obj,container)
            for ch=container.Children
                delete(ch);
            end
        end

        function SetCurrent(obj,src,evnt)
            obj.Parent.SetCurrent(obj.ID);
        end
    end
end
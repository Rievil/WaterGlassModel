classdef InterFig < handle
    properties
        WGGuide;
        UIFig;
        Toolbar;
        Panel;
        TabPanel;
        WGTabList;
        CurrentTab=0;
        ID=0;
    end

    properties (Dependent)
        Count;
    end
    
    

    methods
        function obj=InterFig(~)
            obj.WGGuide=WGGuide("data pro Vlastika_Šablona_2022-10-20.xlsx");
            DrawGUI(obj);
        end

        function count=get.Count(obj)
            count=numel(obj.WGTabList);
        end

        function DrawGUI(obj)
            fig=uifigure;
            obj.UIFig=fig;
            

            obj.Toolbar = uitoolbar(obj.UIFig);

            % New inter
            ptool1 = uipushtool(obj.Toolbar,'ClickedCallback',@obj.MNew,...
                'Tooltip','New interpretation','Icon','plus_sign.gif');

            % Close
            ptool2 = uipushtool(obj.Toolbar,'ClickedCallback',@obj.MClose,...
                'Tooltip','Close interpretation','Icon','cancel_sign.gif');

            % Export
            ptool3 = uipushtool(obj.Toolbar,'ClickedCallback',@obj.MExport,...
                'Tooltip','Export all interpretation','Icon','export_icon.gif');



            g = uigridlayout(fig);
            g.RowHeight = {25,'1x'};
            g.ColumnWidth = {'1x','1x','4x'};
            
%             but1=uibutton(g,'Text','New interpretation','ButtonPushedFcn',@obj.MNew);
%             but1.Layout.Row=1;
%             but1.Layout.Column=1;
% 
%             but2=uibutton(g,'Text','Close interpretation','ButtonPushedFcn',@obj.MClose);
%             but2.Layout.Row=1;
%             but2.Layout.Column=2;


            tabgp = uitabgroup(g);
            tabgp.Layout.Row=[1 2];
            tabgp.Layout.Column=[1 3];
            obj.TabPanel=tabgp;
        end

        function SetCurrent(obj,id)
            obj.CurrentTab=id;
        end

        function state=CheckName(obj,name)
            state=false;
            for i=1:numel(obj.WGTabList)
                tab=obj.WGTabList{i};
                if strcmp(name,tab.Title)
                    state=true;
                    break;
                end
            end
        end
    end

    methods (Access=private)
        function MNew(obj,src,evnt)
            try
                obj.ID=obj.ID+1;
                
                obj1=WGTab(obj,obj.TabPanel,obj.ID);
                
                obj.WGTabList{end+1}=obj1;
            catch ME
%                 delete(obj1);
                obj.ID=obj.ID-1;
            end
            
        end

        function MExport(obj,src,evnt)
            ExportModels(obj);
        end

        function ExportModels(obj)
            T=table;
            for i=1:obj.Count
                wg=obj.WGTabList{i};
                T=[T; Export(wg,i+1)];
            end

            if exist("Interpol.xlsx")
                delete('Interpol.xlsx')
            end
            
            writetable(T,'Interpol.xlsx');
        end



        function MClose(obj,src,evnt)
            if obj.Count>0
                if obj.CurrentTab>0
                    for i=1:obj.Count
                        if obj.WGTabList{i}.ID==obj.CurrentTab
                            obj.WGTabList{i}.delete;
                            obj.WGTabList(i)=[];

                            if obj.CurrentTab>0
                                obj.CurrentTab=0;
                            end
                            break;
                        end
                    end
                else
                    obj.WGTabList{end}.delete;
                    obj.WGTabList(end)=[];
                end
            end

            if obj.Count==0
                obj.ID=0;
            end
        end
    end

end

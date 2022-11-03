classdef WGGuide < handle
    properties
        DataFile;
        Data;
        FData;
        FOData;
        Source;
        Param;
        System;
    end

    methods
        function obj=WGGuide(file)
            obj.DataFile=file;
            obj.Data=readtable(obj.DataFile,'VariableNamingRule','preserve');

            idx=1:1:size(obj.Data,1);
            idx=idx';
            ignore=logical(zeros(size(obj.Data,1),1));
            obj.Data.ID=idx;
            obj.Data.Ignore=ignore;

            MakeSelection(obj);
            obj.Data.('Laboratoř')=string(obj.Data.('Laboratoř'));
            obj.Source=unique(obj.Data.('Laboratoř'));
        end

        function MakeSelection(obj)
            FilterData(obj,"VUT");
            obj.Param=unique(obj.FData.('zlabel'));
            obj.System=unique(obj.FData.('Systém'));
        end




        function FilterData(obj,source)
            T=obj.Data(obj.Data.('Laboratoř')==source,:);
            
            TF=WGGuide.FoldTable(T,[6,7,8,38],1:41,'none');
            idx=[];
            for i=1:size(TF,1)
                Tn=TF.FilteredTable{i};
                Tn=rmmissing(Tn);
                if size(Tn,1)==0
                    idx(end+1)=i;
                end
            end
            
            obj.FOData=TF(idx,:);
            TF(idx,:)=[];
            obj.FData=TF;

            obj.FData.('zlabel')=string(obj.FData.('zlabel'));
            obj.FData.('Systém')=string(obj.FData.('Systém'));
            obj.FOData.('zlabel')=string(obj.FOData.('zlabel'));
            obj.FOData.('Systém')=string(obj.FOData.('Systém'));
        end
    end

    methods (Static)
        function sT=FoldTable(inT,namcol,valcols,varargin)
            org=varargin;
        %     unqVal=cell;
            com=[];
            varnames=inT.Properties.VariableNames;
            for i=1:numel(namcol)
                coldata=inT{:,namcol(i)};
        
                switch class(coldata)
                    case 'cell'
                        coldata=string(coldata);
                    otherwise
                end
                unqVal{i}=unique(coldata);
                unqValNum{i}=1:1:numel(unqVal{i});
                com=[com, sprintf('unqValNum{%d},',i)];
            end
            com(end)=[];
            result=eval(['combvec(',com,');'])';
            
            sT=table;
            for i=1:size(result,1)
                
                B=inT;
                
                
                for j=1:size(result,2)
                    arr=B{:,namcol(j)};
                    idx=arr==unqVal{j}(result(i,j));
                    B=B(idx,:);
                end
                if size(B,1)>0
        
                    oT=table;
                    for i=1:numel(valcols)
                        oT=[oT, table(B{:,valcols(i)},'VariableNames',varnames(valcols(i)))];
                    end
                    
                    rT=B(1,namcol);
                    rT.FilteredTable={oT};
                    org2=org;
                    while numel(org2)>0
                        for k=1:numel(valcols)
                            
                            switch org2{1}
                                case 'none'
                                    skip=true;
                                case 'mean'
                                    name='Mean';
                                    arr=mean(B{:,valcols(k)});
                                    skip=false;
                                case 'std'
                                    name='Std';
                                    arr=std(B{:,valcols(k)});
                                    skip=false;
                                case 'modus'
                                    name='Modus';
                                    arr = mode(B{:,valcols(k)});
                                    skip=false;
                                case 'median'
                                    name='Median';
                                    arr = median(B{:,valcols(k)});
                                    skip=false;
                                case 'max'
                                    name='Max';
                                    arr = max(B{:,valcols(k)});
                                    skip=false;
                                case 'min'
                                    name='Min';
                                    arr = min(B{:,valcols(k)});
                                    skip=false;
                            end
        
                            if ~skip
                                newname=sprintf('%s%s',name,varnames{valcols(k)});
                                ssT=table(arr,'VariableNames',{newname});
                                rT=[rT, ssT];
                            else
                                 rT=rT;
                            end
                        end            
                        org2(1)=[];
                    end
                    
                    sT=[sT; rT];
                end
                
            end
            
        
            
        end
    end

end
function TFF=GetData(filename)
    T=readtable(filename);
    
    names=T.Properties.VariableNames;
    for i=[6,7,8,13,14,15,20,21,22,27,28,29,31,32]
        T.(names{i})=string(T.(names{i}));
    end
    
    
    colidx=[];
    colidx=struct;
    colidx.xlabidx=[6,13,20,27];
    colidx.xval=[1,9,16,23];
    
    colidx.ylabidx=[7,14,21,28];
    colidx.yval=[2,10,17,24];
    
    colidx.zlabidx=[8,15,22,29];
    colidx.zval=[3,11,18,25];
    
    colidx.std=[4,12,19,26];
    
    TF=table;
    fnames=fieldnames(colidx);
    
    for i=1:numel(fnames)
        idx=colidx.(fnames{i});
        TFi=table;
        TFii=table;
        for j=1:numel(idx)
            TFi=[TFi; table(T.(names{idx(j)}),'VariableNames',{fnames{i}})];
            if i==numel(fnames)
                TFii=[TFii; table(T.Laborato_,T.legend,T.Teplota)];
            end
        end
    
        TF=[TF, TFi];
        if i==numel(fnames)
            TFii.Properties.VariableNames={'Lab','Legend','Temperature'};
            TF=[TF, TFii];
        end
    end
    
    TF1=FoldTable(TF,[1,3,5,8,10],[2,4,6,7],'none');
    
    xtype=unique(TF1.xlabidx);
    ytype=unique(TF1.ylabidx);
    
    TFF=TF1(TF1.xlabidx==xtype(4) & TF1.ylabidx==ytype(2),:);
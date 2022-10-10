function [T2]=OrginizeAutocadTable(T)
    T=T;
LineCount=height(T);
X=[T.('Start X'); T.('End X')];
Y=[T.('Start Y'); T.('End Y')];

idx=linspace(1,LineCount,LineCount);
LineID=[idx';idx'];

UnqX=unique(X);
UnqY=unique(Y);
Tail=logical(zeros(numel(X),1));
ID=zeros(numel(X),1);
IDi=0;
for i=1:numel(X)
    IDi=IDi+1;
    XT=X;
    YT=Y;
    
    XF=X(i);
    YF=Y(i);
    
    XT(i)=NaN;
    YT(i)=NaN;
    
    IdX=XT==XF;
    IdY=YT==YF;
    
    ID(i)=IDi;
    if IdX==IdY & sum(IdX)>0
        I=IdX;
        ID(I)=IDi;
    else
        if sum(Tail)==0
            Tail(i)=true;
            I=0;
        end
    end
end
T2=table(X,Y,LineID,ID,Tail);
TZaloha=T2;

First=find(T2.Tail==1);
Last=First(2);
First(2)=[];

Order=zeros(numel(X),1);
n=1;
Order(First)=n;

Tst=1+sum(linspace(2,size(T,1)-1,size(T,1)-1))*2+size(T,1);
TLineID=T2.LineID;
TID=T2.ID;

row=First;
OldLineID=0;
while sum(Order)<Tst
    LineID=T2.LineID(row);
    if LineID==OldLineID
        
    else
        OldLineID=LineID;
        n=n+1;
    end
    
    TLineID(row)=NaN;
    
    rowB=find(TLineID==row);
    if isempty(rowB)
        rowB=find(TID==T2.ID(row));
        TID(rowB,1)=NaN;
        rowB(rowB==row)=[];
        row=rowB;
    else
        row=rowB;
    end
    Order(row)=n;
end
T2=[T2, table(Order)];
[~,I]=sort(T2.Order);
T2=T2(I,:);

UnqOrder=unique(T2.Order);
for i=1:numel(UnqOrder)
    Idx=find(T2.Order==UnqOrder(i));
    if numel(Idx)>1
        T2(Idx(2),:)=[];
    end
end

end
FG = FitGuide;
R=FG.GetData;
%%
unqx=unique(R.x);
unqy=unique(R.y);
unqt=unique(R.T);



mx=linspace(min(unqx),max(unqx),20)';
my=linspace(min(unqy),max(unqy),20)';
mt=linspace(min(unqt),max(unqt),20)';


%%
OutT=table;
f = waitbar(0,'Please wait...');
n=0;
count=numel(mx)*numel(my)*numel(mt);
for i=1:numel(mx)
    for j=1:numel(my)
        for k=1:numel(mt)
            n=n+1;
            [Zv,accv]=FG.GetZ(mx(i),my(j),mt(k),"v");
            
            [Zd,accd]=FG.GetZ(mx(i),my(j),mt(k),"d");
            
            OutT=[OutT; table(mx(i),my(j),mt(k),Zv,accv,Zd,accd,'VariableNames',...
                {'x','y','t','zv','zvacc','zd','zdacc'})];
            waitbar(n/count,f,sprintf('Loading your data: %d/%d',n,count));
        end
    end
end
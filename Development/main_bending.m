path='G:\Můj disk\Škola\Měření\2021\Szymon\Bending';
files=dir(path);
figure;
hold on;
files([files.isdir])=[];
mpat=["REF","W"];
col=lines(6);
for i=1:size(files,1)
    
    filename=[char(files(i).folder) '\' char(files(i).name)];
    T=readtable(filename);
    
    for j=1:numel(mpat)
        k=contains(char(files(i).name),mpat(j));
        if k==true
            break;
        end
    end
    if ~strcmp(files(i).name,'pokus.txt')
        if j==1
            colf=col(6,:);
            label='REF';
        else
            tst=files(i).name(1);
            num=str2double(tst);
            colf=col(num,:);
            label=sprintf('%dW',num);
        end

        [M,I]=max(T.Var3);

        scatter(T.Var2(I),T.Var3(I),'DisplayName',label,'MarkerFaceColor',colf,'MarkerEdgeColor','none');
    end
end
ylim([0 5000]);
xlim([0 1]);
legend;
%%
fig=figure;
subplot(1,3,1);

scatter(T.Var1,T.Var2);


subplot(1,3,2);

plot(T.Var1,T.Var3);

subplot(1,3,3);

plot(T.Var2,T.Var3);
Filename = 'multimedia.m4a';
a=audioread(Filename);
plot(a);
N=32;
for i=2:6
h=linspace(1,1,(i-1)*N);
%形成一个矩形窗，长度为N
En=conv(h,abs(a));
%求卷积得其短时能量函数En
subplot(6,1,i),plot(En);
if(i==2) 
    legend('N=32');
elseif(i==3) 
    legend('N=64');
elseif(i==4) 
    legend('N=128');
elseif(i==5) 
    legend('N=256');
elseif(i==6) 
    legend('N=512');
end
end
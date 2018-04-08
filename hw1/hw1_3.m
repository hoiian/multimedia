Filename = 'multimedia.m4a';
a=audioread(Filename);
[y,fs] = audioread(Filename);
n=length(a);
time=(1:length(a))/fs; 
N=320;
subplot(3,1,1),plot(time,a);

h=linspace(1,1,N);%形成一个矩形窗，长度为N
En=conv(h,a.*a);%求卷积得其短时能量函数En
subplot(3,1,2),plot(N,En);

for i=1:n-1
if a(i)>=0
    b(i)= 1;
else
    b(i) = -1;
end
if a(i+1)>=0
    b(i+1)=1;
else
    b(i+1)=-1; 
end
    w(i)=abs(b(i+1)-b(i)); 
end%求出每相邻两点符号的差值的绝对值
k=1; 
j=0;

while (k+N-1)<n
    Zm(k)=0;
    for i=0:N-1;
        Zm(k)=Zm(k)+w(k+i);
    end
j=j+1;
k=k+160; %每次移动半个窗
end
for w=1:j
    Q(w)=Zm(160*(w-1)+1)/640;%短时平均过零率
end

subplot(3,1,3),plot(Q);




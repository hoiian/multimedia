filename = 'multimedia.m4a';
[y,Fs]=audioread(filename);
data=y;
Frame_size = 20;
Frame_shift = 10;
max_value=max(abs(y));
y=y/max_value;
window_period=Frame_size/1000;
shift_period=Frame_shift/1000;
pitch_freq=0;
t=1/Fs:1/Fs:(length(y)/Fs);
subplot(2,1,1);
plot(t,y);

window_length = window_period*Fs
sample_shift = shift_period*Fs
sum1=0;energy=0;autocorrelation=0;
for i=1:(floor((length(y))/sample_shift)-ceil(window_length/sample_shift))
  k=1;yy=0;
  for j=(((i-1)*sample_shift)+1):(((i-1)*sample_shift)+window_length)
    yy(k)=y(j);
    k=k+1;
  end
  for l=0:(length(yy)-1)
    sum1=0;
    for u=1:(length(yy)-l)
      s=yy(u)*yy(u+l);
      sum1=sum1+s;
    end
    autocor(l+1)=sum1;
    autocorrelation(l+1,i)= autocor(l+1);
  end
  auto=autocor(21:240);
  max1=0;
  for uu=1:220
    if(auto(uu)>max1)
      max1=auto(uu);
      sample_no=uu;
    end 
  end
  pitch_freq(i)=(((1/((20+sample_no)*(1/Fs))*-1)/21)+100)*4.41 ;
end
[rows,cols]=size( autocorrelation);
kkk=1/Fs:shift_period:(cols*shift_period);
subplot(2,1,2);plot(kkk,pitch_freq);
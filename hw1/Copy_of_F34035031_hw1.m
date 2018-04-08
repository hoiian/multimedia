filename = 'multimedia.m4a';
[y,fs]=audioread(filename);
t=1/fs:1/fs:(length(y)/fs);
subplot(5,1,1);plot(t,y);
title('Waveform');
xlabel('time(s)');
%fs=44100


%----------common value init----------%
frame_size=20/1000;
frame_shift=10/1000;
% max_value=max(abs(y));
y=y/max(abs(y));

window_length=frame_size*fs;
sample_shift = frame_shift*fs;

sum1=0;
energy=0;
% w=window(window_type,window_length);
w=rectwin(window_length); %rectangle window function
jj=1;

%------------------energy--------%
for i=1:(floor((length(y))/sample_shift)-ceil(window_length/sample_shift))
    for j=(((i-1)*sample_shift)+1:(((i-1)*sample_shift)+window_length))
        y(j)=y(j)*w(jj);
        jj=jj+1;
        yy=y(j)*y(j);
        sum1=sum1+yy;
    end
    energy(i)=sum1;
    sum1=0;
    jj=1;
end
w=0;
%c=energy;
%a=((i-1)*sample_shift)+window_length;

% tt=1/fs:(frame_shift/1000):(length(energy)*(frame_shift/1000)) ;
tt=(1/fs:(length(energy)))/100;
% ttt=floor((length(y))/sample_shift)-ceil(window_length/sample_shift);
subplot(5,1,2);
plot(tt,energy);
title('Energy');
xlabel('time(s)');


%------zero crossing rate--------%
sum2=0;
energy=0;
w=rectwin(window_length); %rectangle window function
jj=1;

for i=1:(floor((length(y))/sample_shift)-ceil(window_length/sample_shift))
    y(((i-1)*sample_shift)+1)=y(((i-1)*sample_shift)+1)*w(jj);
    jj=jj+1;
    for j=(((i-1)*sample_shift)+2):(((i-1)*sample_shift)+window_length)
        y(j)=y(j)*w(jj);
        jj=jj+1;
        yy=y(j)*y(j-1);
        if(yy<0)
            sum2=sum2+1;
        end
    end
    zerocrossing(i)=sum2/(2*window_length);
    sum2=0;
    jj=1;
end
w=0;

subplot(5,1,3);
plot(tt,zerocrossing);
title('Zero Crossing Rate');
xlabel('time(s)');

%------------------autocorrelation-------
% frame_size=140/1000; %??ms
% window_length=frame_size*fs;
% 
% y=y(1:window_length);
% sum3=0;
% % autoacorr=0;
% for k=0:(length(y)-1)
%     sum3=0;
%     for u=1:(length(y)-k)
%         s=y(u)*y(u+k);
%         sum3=sum3+s;
%     end
%     autocor(k+1)=sum3;
% end
% 
% tt=(1/fs:1/fs:(length(autocor)/fs))*1000;
% subplot(6,1,4);
% plot(tt,autocor);
% title('Autocorrelation on frame size 140.');
% xlabel('frame number');

%..................................
% frame_size=20/1000;
% frame_shift=10/1000;
% y=y/max(abs(y));
% 
% window_length=frame_size*fs;
% sample_shift = frame_shift*fs;
% sum4=0;
% autocorrelation=0;
% autocor1=0;
% 
% for i=1:(floor((length(y))/sample_shift)-ceil(window_length/sample_shift))
%     k=1;
%     yy=0;
%     for j=(((i-1)*sample_shift)+1):(((i-1)*sample_shift)+window_length)
%         yy(k)=y(j);
%         k=k+1;
%     end
%     for l=0:(length(yy)-1)
%         sum4=0;
%         for u=1:(length(yy)-l)
%             s=yy(u)*yy(u+l);
%             sum4=sum4+s;
%         end
%         autocor1(l+1)=sum4;
%         autocorrelation(l+1,i)=autocor1(l+1);
%     end
% end
% 
% [rows,cols]=size(autocorrelation);
% tt=1/fs:1/fs:(length(y)/fs);
% kk=(1/fs:1/fs:(rows/fs))*1000;
% k1=(1/fs:1/fs:(length(autocor1)/fs))*1000;
% % kkk=(1/fs:frame_shift:(cols*frame_shift));
% subplot(6,1,5);
% % plot(kk,autocorrelation);
% plot(k1,autocor1);
          
%-----pitch---------
sum4=0;
energy=0;
autocorrelation=0;
% [y,fs]=audioread(filename);
% y=y/max(abs(y));
pitch_freq=0;


for i=1:(floor((length(y))/sample_shift)-ceil(window_length/sample_shift))
  k=1;yy=0;
  for j=(((i-1)*sample_shift)+1):(((i-1)*sample_shift)+window_length)
    yy(k)=y(j);
    k=k+1;
  end
  for l=0:(length(yy)-1)
    sum4=0;
    for u=1:(length(yy)-l)
      s=yy(u)*yy(u+l);
      sum4=sum4+s;
    end
    autocor(l+1)=sum4;
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
  pitch_freq(i)=(((1/((20+sample_no)*(1/fs))*-1)/21)+100)*4.41 ;
end
[rows,cols]=size( autocorrelation);
kkk=1/fs:frame_shift:(cols*frame_shift);
subplot(5,1,5);
plot(kkk,pitch_freq);
axis([0,4,0,500]);
title('Pitch');
xlabel('time(s)');

%------------end point---------
% opt=endPointDetect('defaultOpt');
% opt.method='volHod';
% showPlot=1;
% endPoint=endPointDetect(au, opt, showPlot);

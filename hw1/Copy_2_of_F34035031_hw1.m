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
% energy=0;
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


          
%--------------------pitch---------%
sum4=0;
% energy=0;
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

%---------------------end point---------%
frameSize = 882;
overlap = 441;
y=y-mean(y);				% zero-mean substraction
%frameMat=buffer2(y, frameSize, overlap);	% frame blocking
%frameNum=size(frameMat, 2);			% no. of frames
frameNum = floor((length(y)-1)/window_length)+1;

volume=energy;	
% volumeTh1=max(volume)*0.1;			% volume threshold 1
volumeTh1=20;
volumeTh2=median(volume)*0.1;			% volume threshold 2
volumeTh3=min(volume)*10;			% volume threshold 3
volumeTh4=volume(1)*5;				% volume threshold 4
index1 = find(volume>volumeTh1);
index2 = find(volume>volumeTh2);
index3 = find(volume>volumeTh3);
index4 = find(volume>volumeTh4);

%sampleIndex=(frameIndex-1)*(frameSize-overlap)+round(frameSize/2);

endPoint1=([index1(1),index1(end)]-1)*(frameSize-overlap)+round(frameSize/2);
endPoint2=([index2(1),index2(end)]-1)*(frameSize-overlap)+round(frameSize/2);
endPoint3=([index3(1),index3(end)]-1)*(frameSize-overlap)+round(frameSize/2);
endPoint4=([index4(1),index4(end)]-1)*(frameSize-overlap)+round(frameSize/2);

% endPoint1=frame2sampleIndex([index1(1), index1(end)], frameSize, overlap);
% endPoint2=frame2sampleIndex([index2(1), index2(end)], frameSize, overlap);
% endPoint3=frame2sampleIndex([index3(1), index3(end)], frameSize, overlap);
% endPoint4=frame2sampleIndex([index4(1), index4(end)], frameSize, overlap);

subplot(5,1,4);
time=(1:length(y))/fs;
plot(time, y);
xlabel('time(s)'); 
title('End point Detection');
axis([-inf inf -1 1]);
% line(time(endPoint1(  1))*[1 1], [-1, 1], 'color', 'm');
% line(time(endPoint2(  1))*[1 1], [-1, 1], 'color', 'g');
% line(time(endPoint3(  1))*[1 1], [-1, 1], 'color', 'k');
line(time(endPoint4(  1))*[1 1], [-1, 1], 'color', 'r');
% line(time(endPoint1(end))*[1 1], [-1, 1], 'color', 'm');
% line(time(endPoint2(end))*[1 1], [-1, 1], 'color', 'g');
% line(time(endPoint3(end))*[1 1], [-1, 1], 'color', 'k');
line(time(endPoint4(end))*[1 1], [-1, 1], 'color', 'r');
% legend('Waveform', 'Boundaries by threshold 1', 'Boundaries by threshold 2', 'Boundaries by threshold 3', 'Boundaries by threshold 4');


THRESHOLD=1.3;
TIME=5;
%capture;
filename = 'multimedia.m4a';
[y,Fs]=audioread(filename);
% Fs = 11025;
% y = wavrecord(TIME*Fs,Fs);
%plot(y)
%wavplay(y,Fs);
samplePerFrame=floor(Fs/100);
bgSampleCount=floor(Fs/5); %according to formula, 1600 sample needed for 8 khz

%----------
%calculation of mean and std
bgSample=[];
for i=1:1:bgSampleCount
    bgSample=[bgSample y(i)];
end
meanVal=mean(bgSample);
sDev=std(bgSample);
%----------
%identify voiced or not for each value
for i=1:1:length(y)
   if(abs(y(i)-meanVal)/sDev > THRESHOLD)
       voiced(i)=1;
       voiced_con(i)=0;
   else
       voiced(i)=0;
       voiced_con(i)=1;
   end
end


% identify voiced or not for each frame
%discard insufficient samples of last frame

usefulSamples=length(y)-mod(length(y),samplePerFrame);
frameCount=usefulSamples/samplePerFrame;
voicedFrameCount=0;
for i=1:1:frameCount
   cVoiced=0;
   cUnVoiced=0;
   for j=i*samplePerFrame-samplePerFrame+1:1:(i*samplePerFrame)
       if(voiced(j)==1)
           cVoiced=(cVoiced+1);
       else
           cUnVoiced=cUnVoiced+1;
       end
   end
   %mark frame for voiced/unvoiced
   if(cVoiced>cUnVoiced)
       voicedFrameCount=voicedFrameCount+1;
       voicedUnvoiced(i)=1;
   else
       voicedUnvoiced(i)=0;
   end
end

silenceRemovedSignal=[];

%-----
for i=1:1:frameCount
    if(voicedUnvoiced(i)==1)
    for j=i*samplePerFrame-samplePerFrame+1:1:(i*samplePerFrame)
            silenceRemovedSignal= [silenceRemovedSignal y(j)];
        end
    end
end

%---display plot and play both sounds
%     figure; plot(y);
    subplot(2,1,1);
    plot(voiced_con);
    subplot(2,1,2);
    plot(silenceRemovedSignal);
%%%play
% sound(y,Fs);
sound(silenceRemovedSignal,Fs);
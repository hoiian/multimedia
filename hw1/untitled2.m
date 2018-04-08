function [datacropped,speechlength,speechflag] = endpoint1(s,fs,win,fl,inc);
%
% Endpoint Detection Using Short-term Energy and Zero-crossing Rate.
% <Inputs>
% datadir : Directory of the txt file containing speech signal.
% fs : Sampling frequency in Hz (Default 8000).
% win : Window type 'R' Rectangular window in time.
% 'N' Hannning window in time.
% 'H' Hamming window in time.
% fl :Frame length (Default 80 samples corresponding to 10 ms).
% inc :Increment in num of samples (Default 40).
% <Outputs>
% datacropped : This returns the cropped speech signal based on endpoint
% detection.
% speechflag : If any speechflag is set for warning any single one or
% combination of the following problems might have occurred.
% 1. Split data file may be corrupt if norm(s)<0.1
% 2. Infinite loop in raw search algorithm for speech
% boundaries if there is no signal detected that has 20 frames or longer
% duration.
% 3. Speech portion of the signal starting too early
% might indicate a possible noise sequence in the beginning due to
% bad recording.
% All above cases need further investigation after cropping speech to determine if
% the cropped data is corrupt.
% speechlength : It is the length of the cropped speech signal.
%
% <References>
% [1] L. R. Rabiner and M. R. Sambur, “An algorithm for determining the endpoints
% of isolated utterances,” The Bell System Technical Journal, February 1975.
%
%------------------------------------------------------------------------------------------------------
%clc, clear('s');
if nargin < 2 fs = 8000; end
if nargin < 3 win = 'R'; end % Default Rectangular Window.
if nargin < 4 fl = fs/100; end % Default frame length is 80 for 10 ms.
if nargin < 5 inc = fl/2; end % Default inc.in overlapping window is 40.
if win == 'R'
% Default Rectangular Window of length 80 for 10 ms frames.
w = rectwin(fl);
else if win =='N' w = hann(fl);
else if win =='H' w = hamming(fl); end
 end
end

%[s,fs]= wavread('KU_BARU.wav');
s=s(:,1);

%s = load(datadir);
sm = s-mean(s); % Takes the mean out of data before processing.
speechflag = 0;

% IIR Elliptical BPF Design
%d = fdesign.bandpass(100/4000,150/4000,2000/4000,2400/4000,60,0.5,60);
%hd = ellip(d);
%sf = filter(hd,sm); % Filters the speech data.

% Design of a first-order pre-emphasis filter
%a = 1;
%b = [1, -15/16];
%sf = filter(b,a,sm);

% IIR Elliptical HPF Design
d = fdesign.highpass('n,fst,fp,ap',10,60/4000,100/4000,0.5);
hd = ellip(d);
sf = filter(hd,sm);

% Checking bad split trials below if any.
if norm(sf) < 1.5; datacropped = []; speechflag = 1; speechlength = 0;
else

% Truncating the data to make it divisible by frame length.
m = floor(length(sf)/inc);
sf = sf(1:m*inc);

% Short-term energy per frame is STE and Zero crossing count
% per frame is ZCR. % 50 overlaping frames taken by default.
for n=1:m-1;
 sw = sf(inc*(n-1)+1:inc*(n-1)+fl).*w; STE(n) = sum(abs(sw));
 for j= 2:fl;
    zc(j)=abs(sign(sw(j))-sign(sw(j-1)))/2;
 end
 ZCR(n) = sum(zc);
end

% Assuming there is no speech during the first 100 ms of recordings,
% Mean and standard deviation of ZCR and STE for the first ten frames.
avgzcr = mean(ZCR(1:10)); stdzcr = std(ZCR(1:10));
avgste = mean(STE(1:10)); stdste = std(STE(1:10));

% Setting up STE Upper and Lower Thresholds and ZCR Threshold.
IF = fl/4; % 20 crossings per 10 ms is a fixed value when N=160;
IZCT = min(IF,avgzcr+stdzcr); % Zero-crossing Rate Threshold.
IE = 0.15; % Upper level for avgste in case high noise
% present in first 20 frames.
minste = min(IE,avgste+stdste);
ITL = 8*minste; % Lower threshold for STE.
ITU = 32*minste; % Upper threshold for STE.
FT = (ITU-ITL)/2 + ITL; % Fine threshold for STE.

% Following algorithm firsts makes a raw search for endpoint detection
% based on STE, ITU and UTL. Then it refines the speech boundaries using
% ZCR and IZCT for the successive and preceding 6 frames forth and back.
% If the interval btwn rawstart and rawend is less than 100 ms (20 frames)
% algorithm assumes that it is just a click noise (or a spike), not speech.

duration = 0; rawend = 0; rawstart = 0; loopn =0; d = 1; refindex = 0;
while duration < 80; % Raw search for speech boundaries starts.
 for n = d:m-1
  if STE(n) > ITU;
   refindex = n; rawstart = n;
   for l = refindex:-1.0:1
    if STE(l) < FT; rawstart = l; break; end
   end
 break;
% If STE of speech signal does not exceed upper threshold, ITU is set to ITU = ITU/2
% and makes one more search.
else if n == m-1;
  ITU = ITU/2; FT = FT/2;
  for v = 1:m-1
   if STE(v) > ITU;

refindex = v; rawstart = v;
  for p = refindex:-1.0:1   
    if STE(p) < FT; rawstart = p; break; end
  end
break;
   end
  end
 end
 end
end
if refindex ~= 0;
for k = refindex:m-1
 if STE(k) < FT; rawend = k; break; end
end
end
duration = rawend - rawstart; % If duration < 20 frames, it keeps scanning.
if (duration == 0); speechflag =2; break; end
if (duration < 0); speechflag =3; break; end
loopn = loopn+1;
if loopn > 10; speechflag = 4; speechlength = 0; break; end % Prevents infinite loop.
d = rawend+1;
end

% Fine search using total number of intervals crossing threshold of ZCR.
finestart = rawstart; fineend = rawend;

if (duration>23)&&(duration<50)
nzc = 0; update = 0;
if (rawstart-6) > 0;
for n = rawstart:-1:(rawstart-6)
 if ZCR(n) > IZCT; nzc = nzc+1; update = n; end
end
if nzc > 3; finestart = update; end
end

nzc = 0; update = 0;
if ((rawend+6) < length(ZCR))&&(rawend ~= 0);
for n = rawend:(rawend+6)
 if ZCR(n) > IZCT; nzc = nzc+1; update = n; end
end
 if nzc > 3; fineend = update; end
end
end

starti = inc*(finestart)+1;
endi = inc*(fineend);

if (endi-starti) > 878;
speechlength = endi-starti;
datacropped = sf(starti:endi);
speechflag = 0;
else speechlength = 0; datacropped = sf;
end                                                                                  
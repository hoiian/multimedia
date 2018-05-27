pic = imread('pic3.png');
subplot(1,3,1);
imshow(pic);

bw = uint8((1/3)*(double(pic(:,:,1))+double(pic(:,:,1))+double(pic(:,:,3))));
% subplot(2,2,3);
% imshow(bw);

imh = imadjust(bw,[0.3,0.6],[0.0,1.0]);
subplot(1,3,2);
imshow(imh);

imh1 = histeq(bw);
% subplot(2,2,2);
% imshow(imh1);

test = edge(imh,'sobel');
subplot(1,3,3);
imshow(test);

bw_db = double(bw);
maskx = [-1 -2 -1;0 0 0;1 2 1];
[r,c] = size(bw);
out = zeros(r-3,c-3);
for idx = 1:(r-3)
    for jdx = 1:(c-3)

        bwsq = bw_db(idx:(idx+2),jdx:(jdx+2));
        res = maskx.*bwsq;
        out(idx,jdx) = sum(sum(res))*0.005;
    end
end

gx = out;

% subplot(2,2,4);
% imshow(gx);

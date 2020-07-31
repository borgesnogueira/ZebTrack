function [fundo, V] = criaFundoAoVivo(waitbar)
videoLive = videoinput('winvideo');
triggerconfig(videoLive, 'manual');
%src = getselectedsource(videoLive);
%videoLive.FramesPerTrigger = 300;
start(videoLive);
data = getsnapshot(videoLive);
size(data);
frame = double(data);
sframe = frame;
%novo c�digo
fundopb = rgb2gray(uint8(frame));
Mpb = rgb2gray(uint8(frame)).^2;
M2 = frame.^2;
%novo c�digo
numFrames = 50;
for i = 1:numFrames
    data = getsnapshot(videoLive);
    frame = double(data);
    f = frame;
    f = double(f);
    sframe = sframe + f;
    fundopb = fundopb + rgb2gray(uint8(f));
    Mpb = Mpb + rgb2gray(uint8(f));
    M2 = M2 + f.^2;
    waitbar.setvalue(i/numFrames);
    drawnow
    pause(1/4)
end
delete(videoLive);
fundo = sframe/numFrames;
imwrite(uint8(fundo), './live/live.jpeg');
%imshow(uint8(fundo));
fundo = uint8(fundo);
V = M2/numFrames - double(fundo.^2);
V(:, :, 4) = Mpb/numFrames - fundopb.^2;
save('./live/V', 'V');
%close(videoFundo);
%criafundo('C:\Users\jonatas\OneDrive\Documentos\GitHub\ZebTrack\','live.avi');
%depois de gerar um vídeo com os snapshots da webcam
%foi usada a função já existente criafundo para criar o fundo a partir
%do vídeo ao vivo
end

function fundo = criaFundoAoVivo(waitbar)
videoLive = videoinput('winvideo');
triggerconfig(videoLive, 'manual');
%cria um objeto videoinput, com o adptador e formatos suportados pelo
%hardware da maquina onde será executado o programa
src = getselectedsource(videoLive);
%videoLive.FramesPerTrigger = 300;
%definição da quantidade de frames capturados para gerar o video que
%será usado para criação do fundo
start(videoLive);
%funções para iniciar a captura dos frames e mostrar na tela
%videoFundo = VideoWriter('C:\Users\jonatas\OneDrive\Documentos\GitHub\ZebTrack\\live.avi', 'Uncompressed AVI');
%open(videoFundo);
%criando um objeto videowriter
data = getsnapshot(videoLive);
size(data);
frame = double(data);
sframe=frame;
numFrames = 100;
for ii = 1:numFrames
    data = getsnapshot(videoLive);
    frame = double(data);
    %size(frame)
    %writeVideo(videoFundo, data(:,:,:,ii));
    f = frame;
    f = double(f);
    sframe = sframe + f;
    waitbar.setvalue(ii/numFrames);
    drawnow
end
%disp('aaeee');
delete(videoLive);
fundo = sframe/numFrames;
imwrite(uint8(fundo), './live/live.jpeg');
%imshow(uint8(fundo));
fundo = uint8(fundo);
%close(videoFundo);
%criafundo('C:\Users\jonatas\OneDrive\Documentos\GitHub\ZebTrack\','live.avi');
%depois de gerar um vídeo com os snapshots da webcam
%foi usada a função já existente criafundo para criar o fundo a partir
%do vídeo ao vivo
end

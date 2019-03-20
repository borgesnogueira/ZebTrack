function fundo = criaFundoAoVivo()
videoLive = videoinput('winvideo', 1);
%cria um objeto videoinput, com o adptador e formatos suportados pelo
%hardware da maquina onde ser� executado o programa
src = getselectedsource(videoLive);
%videoLive.FramesPerTrigger = 300;
%defini��o da quantidade de frames capturados para gerar o video que
%ser� usado para cria��o do fundo
start(videoLive);
%fun��es para iniciar a captura dos frames e mostrar na tela
%videoFundo = VideoWriter('C:\Users\jonatas\OneDrive\Documentos\GitHub\ZebTrack\\live.avi', 'Uncompressed AVI');
%open(videoFundo);
%criando um objeto videowriter
disp('entrou na fun��o');
data = getsnapshot(videoLive);
size(data);
frame = double(data);
sframe=frame;
numFrames = 600;
for ii = 1:numFrames
    data = getsnapshot(videoLive);
    frame = double(data);
    size(frame)
    %writeVideo(videoFundo, data(:,:,:,ii));
    f = frame;
    f = double(f);
    sframe = sframe + f;
end
disp('aaeee');
delete(videoLive);
fundo = sframe/numFrames;
imwrite(uint8(fundo), 'live.jpg');
imshow(uint8(fundo));
%close(videoFundo);
%criafundo('C:\Users\jonatas\OneDrive\Documentos\GitHub\ZebTrack\','live.avi');
%depois de gerar um v�deo com os snapshots da webcam
%foi usada a fun��o j� existente criafundo para criar o fundo a partir
%do v�deo ao vivo
end
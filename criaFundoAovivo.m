function fundo = criaFundoAoVivo()
videoLive = videoinput('winvideo', 1, 'MJPG_848x480');
%cria um objeto videoinput, com o adptador e formatos suportados pelo
%hardware da maquina onde ser� executado o programa
src = getselectedsource(videoLive);
videoLive.FramesPerTrigger = 300;
%defini��o da quantidade de frames capturados para gerar o video que
%ser� usado para cria��o do fundo
start(videoLive);
%fun��es para iniciar a captura dos frames e mostrar na tela
videoFundo = VideoWriter('C:\Users\jonatas\OneDrive\Documentos\GitHub\ZebTrack\\live.avi', 'Uncompressed AVI');
open(videoFundo);
%criando um objeto videowriter
data = getdata(videoLive, videoLive.FramesAvailable);
frame = double(data(:,:,:,1));
numFrames = size(data, 4);
for ii = 2:numFrames
    writeVideo(videoFundo, data(:,:,:,ii));
    f = data(:,:,:,ii);
    f = double(f);
    frame = frame + f;
end
fundo = frame/numFrames;
imwrite(uint8(fundo), 'C:\Users\jonatas\OneDrive\Documentos\GitHub\ZebTrack\live.jpg');
close(videoFundo);
%criafundo('C:\Users\jonatas\OneDrive\Documentos\GitHub\ZebTrack\','live.avi');
%depois de gerar um v�deo com os snapshots da webcam
%foi usada a fun��o j� existente criafundo para criar o fundo a partir
%do v�deo ao vivo
end
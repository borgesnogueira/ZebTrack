function fundo = criaFundoAoVivo()
    videoLive = videoinput('winvideo', 1, 'MJPG_848x480');
    %cria um objeto videoinput, com o adptador e formatos suportados pelo
    %hardware da maquina onde será executado o programa
    src = getselectedsource(videoLive);
    videoLive.FramesPerTrigger = 200;
    %definição da quantidade de frames capturados para gerar o video que
    %será usado para criação do fundo
    preview(videoLive);
    start(videoLive);
    stoppreview(videoLive);
    %funções para iniciar a captura dos frames e mostrar na tela
    videoFundo = VideoWriter('C:\Users\jonatas\OneDrive\Documentos\GitHub\ZebTrack\live.avi', 'Uncompressed AVI');
    open(videoFundo);
    %criando um objeto videowriter
    data = getdata(videoLive, videoLive.FramesAvailable);
    numFrames = size(data, 4);
    for ii = 1:numFrames
        writeVideo(videoFundo, data(:,:,:,ii));
    end
    close(videoFundo);
    criafundo('C:\Users\jonatas\OneDrive\Documentos\GitHub\ZebTrack\','live.avi'); 
    %depois de gerar um vídeo com os snapshots da webcam
    %foi usada a função já existente criafundo para criar o fundo a partir
    %do vídeo ao vivo
end
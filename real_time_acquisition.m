video = videoinput('winvideo', 1, 'I420_320x240');
%inicia um objeto videoinput que acessa a webcam, o entrada, no caso a web
%cam seria '1' o tipo de imagem e a resolução
set(video, 'FramesPerTrigger', inf);
set(video, 'ReturnedColorspace', 'rgb');
video.FrameGrabInterval = 5;
%o tempo em milisegundos que o vídeo captura um frame da webcam
start(video);
video_processing = VideoWriter('tempo_real.avi','Indexed AVI');
%iniciando a captura
open(video_processing);
while(video.FramesAcquired <= 200)
    frame = getsnapshot(video);
    %exibindo na tela cada frame do vídeo
    imshow(frame);
    writeVideo(video_processing, frame);
    %lembrando que para nossa aplicação precisamos de um objeto vídeo,
    %então devemos usar um loop para gerar um video com o frames adquiridos
    %e depois processá-los
end
close(video_processing);
%referências
%https://la.mathworks.com/help/supportpkg/usbwebcams/ug/webcam.html
%https://la.mathworks.com/help/imaq/videoinput.html
%https://la.mathworks.com/help/imaq/obj2mfile.html
%https://la.mathworks.com/help/imaq/examples/managing-image-acquisition-objects.html
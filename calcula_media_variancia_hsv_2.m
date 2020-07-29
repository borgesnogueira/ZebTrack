%{
Para esse código, estou deliberadamente ignorando a dica
%}

function [media, variancia] = calcula_media_variancia_hsv_2(video, tempo_inicial, tempo_final ...
                                                       , Imback, V, nanimais, mascara, minpix, maxpix, tol, avi, criavideo, tipsubfundo ...
                                                       , caixa, l, c ...
                                                       , colorida, cor, tipfilt ...
                                                       , INTENSIDADE)


    [frame_inicial, frame_final] = extraiIntervaloFrames(tempo_inicial, tempo_final, video); %aqui obtenho os índices final e inicial para a calibração.
    new_video = VideoReader([video.Path,'\',video.Name]); % preciso criar um novo VideoReader pra evitar um bug  
    frames_video = read(new_video, floor([frame_inicial, frame_final]));                         %cria um vetor com todos os frames entre frame_incial e frame_final.
                                                                                             %Lembrando que para acessar o i-ésimo frame, uso a notação frames_video(:,:,:,i);                                                   
    length_frames_video = (floor(frame_final) - floor(frame_inicial)) + 1;                   %Necessário para a implementação do for (o +1 é pra incluir o primeiro termo!)
    %disp(['frame_inicial =', num2str(frame_inicial),'; frame_final = ',num2str(frame_final)]);                                                                                             
    %media = 0;
    %variancia = 1;
end


%Função para converter meu tempo inicial e final em termos dos frames correspondentes.
function [frame_inicial, frame_final] = extraiIntervaloFrames(tempo_inicial, tempo_final, video)
    frame_inicial = video.FrameRate*tempo_inicial;
    frame_final = video.FrameRate*tempo_final;  
end


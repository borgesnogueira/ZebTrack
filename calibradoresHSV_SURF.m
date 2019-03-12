%A ideia é que o usuário defina um intervalo em (tempo_inicial - tempo_final)
%de qualquer extensão de forma que o mesmo possibilite gerar uma biblioteca
%de pontos resultante de múltiplos SURFS em múltiplos frames e uma média e
%variância correspondente a cada peixe

%OBS:
%tolerancia = threshrold na track.m, que serve para a subtração de fundo.


%media e variancia são dois vetores, já que posso ter mais de 1 peixe.
function [media, variancia] = calculaMediaVarianciaHSV(video_rastreio, tempo_inicial, tempo_final, ...
                                                       ,Imwork, Imback, V, n, mascara, minpix, maxpix, tol, avi, criavideo, tipsubfundo)

    [frame_inicial, frame_final] = extraiIntervaloFrames(tempo_inicial, tempo_final, video_rastreio); %aqui obtenho os índices final e inicial para a calibração.
    frames_video = read(video_rastreio, [frame_inicial, frame_final]);      %cria um vetor com todos os frames entre frame_incial e frame_final.
                                                                            %Lembrando que para acessar o i-ésimo frame, uso a notação frames_video(:,:,:,i);
    
    %variáveis de controle do for, média e variância.
    length_frames_video = (frame_final - frame_inicial) + 1;                %Necessário para a implementação do for (o +1 é pra incluir o primeiro termo!)
                                                                            
    %loop para pegar a média e a variância dos frames do vídeo.
    for i=1:1:length_frames_video
        
    end
    
end


%Função para converter meu tempo inicial e final em termos dos frames correspondentes.
function [frame_inicial, frame_final] = extraiIntervaloFrames(tempo_inicial, tempo_final, video_rastreio)
    frame_inicial = video_rastreio.FrameRate*tempo_inicial;
    frame_final = video_rastreio.FrameRate*tempo_final;  
end


function frames_video = geraVetor_frames_video(video_rastreio, frame_inicial, frame_final)
    frames_video = read(video_rastreio, [frame_inicial frame_final]);
end

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
    media = 0; % forcei ser igual a 0 pra não dar bug, trocar depois
    variancia = 1; % forcei ser igual a 1 pra não dar bug, trocar depois
    
    avg_vector_pra_cada_frame = cell(1,length_frames_video);
    
    for i=1:1:length_frames_video
        %figure('Name',['frame ',num2str(i)],'NumberTitle','off');
        %imshow(frames_video(:,:,:,i));
        %converte pra tons de cinza e double pra trabalhar
        if colorida || (cor == 1)
            wframe = double(frames_video(:,:,:,i));
        else
            wframe  = double(rgb2gray(frames_video(:,:,:,i)));
        end
        
        [~, ~, ~, boundingbox, ndetect, ~,~ ,wframe_log] = extractnblobs(wframe, Imback, V, nanimais, mascara, minpix, maxpix, tol, avi, criavideo, tipsubfundo);
        
        avg_vector_pra_cada_frame{1,i} = blob_colours_2(frames_video(:,:,:,i),boundingbox,ndetect,wframe_log,0.15,0.5);
        
    end    
end


%Função para converter meu tempo inicial e final em termos dos frames correspondentes.
function [frame_inicial, frame_final] = extraiIntervaloFrames(tempo_inicial, tempo_final, video)
    frame_inicial = video.FrameRate*tempo_inicial;
    frame_final = video.FrameRate*tempo_final;  
end


%{
Para esse código, estou deliberadamente ignorando a dica (dicax,dicay)
%}

function [media, variancia] = calcula_media_variancia_hsv_2(video, tempo_inicial, tempo_final ...
                                                       , Imback, V, nanimais, mascara, minpix, maxpix, tol, avi, criavideo, tipsubfundo ...
                                                       , colorida, cor ...
                                                       , value_threshold, saturation_threshold, how_many_replicates)

    
    [frame_inicial, frame_final] = extraiIntervaloFrames(tempo_inicial, tempo_final, video); %aqui obtenho os índices final e inicial para a calibração.
    new_video = VideoReader([video.Path,'\',video.Name]); % preciso criar um novo VideoReader pra evitar um bug  
    frames_video = read(new_video, floor([frame_inicial, frame_final]));                         %cria um vetor com todos os frames entre frame_incial e frame_final.
                                                                                             %Lembrando que para acessar o i-ésimo frame, uso a notação frames_video(:,:,:,i);                                                   
    length_frames_video = (floor(frame_final) - floor(frame_inicial)) + 1;                   %Necessário para a implementação do for (o +1 é pra incluir o primeiro termo!)    
    avg_vector_pra_cada_frame = [];
    
    for i=1:1:length_frames_video
        %converte pra tons de cinza e double pra trabalhar
        if colorida || (cor == 1)
            wframe = double(frames_video(:,:,:,i));
        else
            wframe  = double(rgb2gray(frames_video(:,:,:,i)));
        end
        
        [~, ~, ~, boundingbox, ndetect, ~,~ ,wframe_log] = extractnblobs(wframe, Imback, V, nanimais, mascara, minpix, maxpix, tol, avi, criavideo, tipsubfundo);
        
        avg_vector_pra_cada_frame = [avg_vector_pra_cada_frame; cell2mat( blob_colours_2(frames_video(:,:,:,i),boundingbox,ndetect,wframe_log,value_threshold,saturation_threshold) )]; % 0.15, 0.5        
    end    
    
    [idx,media] = kmeans(avg_vector_pra_cada_frame, 2,'Replicates',how_many_replicates); % I recommend 5

    unique_idx = unique(idx);
    variancia = []; % matrix of variations

    for index = 1:1:nanimais
       variancia = [variancia; var(avg_vector_pra_cada_frame(idx==unique_idx(index),:))];
    end   
end


%Função para converter meu tempo inicial e final em termos dos frames correspondentes.
function [frame_inicial, frame_final] = extraiIntervaloFrames(tempo_inicial, tempo_final, video)
    frame_inicial = video.FrameRate*tempo_inicial;
    frame_final = video.FrameRate*tempo_final;  
end


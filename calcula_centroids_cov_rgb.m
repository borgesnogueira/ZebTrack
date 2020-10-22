%{
Para esse código, estou deliberadamente ignorando a dica (dicax,dicay)
%}

function [centroids, cov_matrices] = calcula_centroids_cov_rgb(video, tempo_inicial, tempo_final ...
                                                       , Imback, V, nanimais, mascara, minpix, maxpix, tol, avi, criavideo, tipsubfundo ...
                                                       , colorida, cor ...
                                                       , value_threshold, saturation_threshold, how_many_replicates, handles)
disp(['tempo_inicial = ',int2str(tempo_inicial), ';  tempo_final= ', int2str(tempo_final)]);
disp([video.name,' , nanimais= ',int2str(nanimais),' , maxpix = ',int2str(maxpix),', minpix= ',int2str(minpix)])
disp(['tol=', int2str(tol),', avi= ',int2str(avi),'criavideo=', int2str(criavideo),'tipsubfundo= ',int2str(tipsubfundo)]);
disp(['colorida= ',int2str(colorida),' cor= ',int2str(cor)]);
%figure('Name','Mascara','NumberTitle','off');
%imshow(mascara);
%figure('Name','Imback','NumberTitle','off');
%imshow(Imback);
    [frame_inicial, frame_final] = extraiIntervaloFrames(tempo_inicial, tempo_final, video); %aqui obtenho os índices final e inicial para a calibração.
    new_video = VideoReader([video.Path,'\',video.Name]); % preciso criar um novo VideoReader pra evitar um bug  
    %frames_video = read(new_video, floor([frame_inicial, frame_final]));                         %cria um vetor com todos os frames entre frame_incial e frame_final.
                                                                                             %Lembrando que para acessar o i-ésimo frame, uso a notação frames_video(:,:,:,i);                                                   
    length_frames_video = (floor(frame_final) - floor(frame_inicial)) + 1;                   %Necessário para a implementação do for (o +1 é pra incluir o primeiro termo!)    
    avg_vector_pra_cada_frame = [];
    frame = read(new_video, floor(frame_inicial));
    [l,c,nc] = size(frame);
     vcores = [0 0 1; 1 0 0; 0 1 0; 1 1 1; 1 1 0; 1 0 1; 0 1 1];
     V =  V.^.5;
    %garante que todo mundo em Vrm eh no m�nimo 0.5
    V(V<0.5) = 0.5;
      
    for i = frame_inicial:frame_final
        %converte pra tons de cinza e double pra trabalhar
        frame = read(new_video, floor(i));
        if colorida || (cor == 1)
            wframe = double(frame);
        else
            wframe  = double(rgb2gray(frame));
        end
        
        [~, ~, ~, boundingbox, ndetect, ~,~ ,wframe_log] = extractnblobs(wframe, Imback, V, nanimais, mascara, minpix, maxpix, tol, avi, criavideo, tipsubfundo);
        
        avg_vector_pra_cada_frame = [avg_vector_pra_cada_frame; cell2mat( blob_colours_2(frame,boundingbox,ndetect,wframe_log,value_threshold,saturation_threshold) )]; % 0.15, 0.5        
        
         %plota no GUI
        set(0,'CurrentFigure',handles.figure1);
        set(handles.figure1,'CurrentAxes',handles.axes4);
        hold off
        imhandle = imshow(frame);
        hold on
        for j=1:ndetect
            xi = max(1,boundingbox(j,1) - 3);
            yi = max(1,boundingbox(j,2) - 3);
            xf = min(boundingbox(j,1) + boundingbox(j,3) + 3,c);
            yf = min(boundingbox(j,2) + boundingbox(j,4) + 3,l); 
            phandle = line([xi xf xf xi xi],[yi yi yf yf yi],'Color',vcores(mod(j,7)+1,:));
            thandle = text(xi+2,yi+7,num2str(j),'FontSize',11,'Color',vcores(mod(j,7)+1,:));
        end
        handles.waibar.setvalue((i-frame_inicial)/ length_frames_video);
       drawnow
        
    end    
       
    [idx,centroids] = kmeans(avg_vector_pra_cada_frame, nanimais,'Replicates',how_many_replicates); % I recommend 5
    
    unique_idx = unique(idx);
    cov_matrices = {}; % matrix of variations

    % remover depois
    figure;
    plot3(avg_vector_pra_cada_frame(idx==1,1),avg_vector_pra_cada_frame(idx==1,2),avg_vector_pra_cada_frame(idx==1,3),'r.','MarkerSize',12)
    hold on
    plot3(avg_vector_pra_cada_frame(idx==2,1),avg_vector_pra_cada_frame(idx==2,2),avg_vector_pra_cada_frame(idx==2,3),'b.','MarkerSize',12)
    plot3(centroids(:,1),centroids(:,2),centroids(:,3),'kx','MarkerSize',15,'LineWidth',3) 
    legend('Cluster 1','Cluster 2','Centroids','Location','NW')
    title 'Cluster Assignments and Centroids'
    grid on
    hold off
    % remover depois
    
    for index = 1:1:nanimais
       cov_matrices{index} = cov(avg_vector_pra_cada_frame(idx==unique_idx(index),:));
    end   
end


%Função para converter meu tempo inicial e final em termos dos frames correspondentes.
function [frame_inicial, frame_final] = extraiIntervaloFrames(tempo_inicial, tempo_final, video)
    frame_inicial = floor(video.FrameRate*tempo_inicial);
    frame_final = floor(video.FrameRate*tempo_final);  
end


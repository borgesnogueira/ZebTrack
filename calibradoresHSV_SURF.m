%A ideia é que o usuário defina um intervalo em (tempo_inicial - tempo_final)
%de qualquer extensão de forma que o mesmo possibilite gerar uma biblioteca
%de pontos resultante de múltiplos SURFS em múltiplos frames e uma média e
%variância correspondente a cada peixe

%OBS:
%tol = threshrold na track.m, que serve para a subtração de fundo;
%Imback = wbackg do track.m;
%criavideo = criavideodiff do track.m;
%avi = aviobj2 do track.m (o input e não o output nessa função!);
%wframe = working frame (double e em greyscale);
%frames_video(i) = frame do track.m;
%CORDOPEIXE = intervalo do H do peixe em questão (um vetor);


%media e variancia são dois vetores, já que posso ter mais de 1 peixe.
function [media, variancia] = calculaMediaVarianciaHSV(video, tempo_inicial, tempo_final ...
                                                       , Imback, V, nanimais, mascara, minpix, maxpix, tol, avi, criavideo, tipsubfundo ...
                                                       , pxa, pya, detectado, dicax, dicay, caixa, l, c ...
                                                       , colorida, cor, tipfilt ...
                                                       , CORDOPEIXE)

    [frame_inicial, frame_final] = extraiIntervaloFrames(tempo_inicial, tempo_final, video); %aqui obtenho os índices final e inicial para a calibração.
    frames_video = read(video, [frame_inicial, frame_final]);                                %cria um vetor com todos os frames entre frame_incial e frame_final.
                                                                                             %Lembrando que para acessar o i-ésimo frame, uso a notação frames_video(:,:,:,i);
    
    %variáveis de controle do for, média e variância.
    length_frames_video = (frame_final - frame_inicial) + 1;                                 %Necessário para a implementação do for (o +1 é pra incluir o primeiro termo!)
    
    media = 0;
    mediaBlobsEmFrame = 0;
    mediaFrameIndividual = 0; %(Em 1 peixe e muda em cada loop).
    
    
    
    %LOOP PRINCIPAL
    for i=1:1:length_frames_video
         
        %converte pra tons de cinza e double pra trabalhar
        if colorida || (cor == 1)
            wframe = double(frames_video(i));
        else
            wframe  = double(rgb2gray(frames_video(i)));
        end
        
        
        %faz a diferenca so na area de interesse e extrai o centro de massas
        %das regioes (blobs) maiores que minpix
        [cx, cy, radius, boundingbox, ndetect, aviobj2, imdif] = extractnblobs(wframe, Imback, V, nanimais, mascara, minpix, maxpix, tol, avi, criavideo, tipsubfundo);
    
        %vetor que irá decorar cada animal que ja foi associado a um blob
        detectado = zeros(nanimais);
    
        if cont>1 %global variable;

            if  tipfilt == 1
                %previsao do filtro de kalman
                for j=1:nanimais
                    pdecorada = [px(j,cont-1); py(j,cont-1)];
                    predita = A*[pdecorada;v(:,j)] + Bu;
                    %garantir que esta dentro da imagem
                    predita(1) = min(max(predita(1),1),c);
                    predita(2) = min(max(predita(2),1),l);
                    px(j,cont-1) = predita(1);
                    py(j,cont-1) = predita(2);
                    v(:,j) = predita(3:4);
                end
            end
            
            
            %OLHAR POR PXN E PXY
            [pxn(:,cont), pyn(:,cont), detectado, caixa] = associateeuclid(nanimais, ndetect, px(:,cont-1), py(:,cont-1), cx, cy, radius, boundingbox, detectado, dicax, dicay ...
                                                                        , caixa, l, c, frames_video(i));
        end
        
        %parte que trata das médias.
        frameHSV = rgb2hsv(frames_video(i));
        
        %percorrendo de k=1 até o numero de animais (podemos ter mais de um blob por frame)
        for k=1:1:ndetect %blob individual do frame
            HuePartMatrix = frameHSV(:,:,1); % m x n HUE matrix.
            
            sizeOfBlob = 0; %number of pixels/blob;
            
            for m=caixa(k, floor(1)):1:( caixa(k, floor(1)) + caixa(k,3) )   %1 = x0, 2=y0, 3=width, 4=height; (goes from 'x0' to 'x0 + widith')
                for n=caixa(k, floor(2)):1:( caixa(k, floor(2)) + caixa(k,4) )                                %(goes from 'y0' to 'y0 + height')
                    if(HuePartMatrix(m,n) >= 0 && HuePartMatrix(m,n) <= 15) %testando para o vermelho aqui.
                        mediaFrameIndividual = mediaFrameIndividual + HuePartMatrix(m,n);
                        sizeOfBlob = sizeOfBlob + 1;
                    end
                end
            end
            
            mediaFrameIndividual = mediaFrameIndivual/sizeOfBlob;
            mediaBlobsEmFrame = mediaBlobsEmFrame + mediaFrameIndividual;
            
            %zerando as variáveis de controle
            sizeOfBlob = 0;
            mediaFrameIndividual = 0;
        
        end
        
        mediaBlobsEmFrame = mediaBlobsEmFrame/ndetect;
        media = media + mediaBlobsEmFrame;
        
        %zerando as variáveis de média locais
        mediaBlobsEmFrame = 0;
        
    end
    
    media = media/length_frames_video;  %MEDIA FINAL CALCULADA
    
    
end
    
    


%Função para converter meu tempo inicial e final em termos dos frames correspondentes.
function [frame_inicial, frame_final] = extraiIntervaloFrames(tempo_inicial, tempo_final, video)
    frame_inicial = video.FrameRate*tempo_inicial;
    frame_final = video.FrameRate*tempo_final;  
end


function frames_video = geraVetor_frames_video(video, frame_inicial, frame_final)
    frames_video = read(video, [frame_inicial frame_final]);
end


%function [cc,cr,radius,boundingbox,ndetect,avi,foremm] = extractnblobs(Imwork,Imback,V,n,mascara,minpix,maxpix,tol,avi,criavideo,tipsubfundo)
%function [pxn,pyn,detectado,caixa] = associateeuclid(nanimais,ndetect,pxa,pya,cx,cy,radius,boundingbox,detectado,dicax,dicay,caixa,l,c,frame)

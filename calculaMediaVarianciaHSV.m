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
%INTENSIDADE = intervalo que dita o valor do V de HSV, ou seja, dita o limite para que as cores sejam mais 'intensas';
%V = Vrm do track.m;


%media e variancia são dois vetores, já que posso ter mais de 1 peixe.
function [media, variancia] = calculaMediaVarianciaHSV(video, tempo_inicial, tempo_final ...
                                                       , Imback, V, nanimais, mascara, minpix, maxpix, tol, avi, criavideo, tipsubfundo ...
                                                       , caixa, l, c ...
                                                       , colorida, cor, tipfilt ...
                                                       , INTENSIDADE)
    %ainda não se entrou em um consenso para um bom valor para a
    %intensidade, por isso, os valores abaixo foram pré-setados.
    
    %variáveis que preciso para o funcionamento do código mas que não faz
    %sentido passar como parâmetros.
    dicax = -1;
    dicay = -1;
    
    pxant = zeros(1,nanimais);
    pyant = zeros(1,nanimais);
    
    [frame_inicial, frame_final] = extraiIntervaloFrames(tempo_inicial, tempo_final, video); %aqui obtenho os índices final e inicial para a calibração.
    
    frames_video = read(video, floor([frame_inicial, frame_final]));                                %cria um vetor com todos os frames entre frame_incial e frame_final.
                                                                                             %Lembrando que para acessar o i-ésimo frame, uso a notação frames_video(:,:,:,i);
    
    %VARIÁVEIS DE CONTROLE DO FOR: MÉDIA E VARIÂNCIA.
    length_frames_video = (floor(frame_final) - floor(frame_inicial)) + 1;                                 %Necessário para a implementação do for (o +1 é pra incluir o primeiro termo!)
    
    mediaTOTAL = zeros(nanimais, length_frames_video); %aloco somente um espaço do V (HSV) para cada animal e frames_video espaços (a progressão temporal de cada animal)
    mediaFrameIndividual = 0; %(Em 1 peixe e muda em cada loop).
        
    %LOOP PRINCIPAL
    for i=1:1:length_frames_video
         
        %converte pra tons de cinza e double pra trabalhar
        if colorida || (cor == 1)
            wframe = double(frames_video(:,:,:,i));
        else
            wframe  = double(rgb2gray(frames_video(:,:,:,i)));
        end
        
        
        %faz a diferenca so na area de interesse e extrai o centro de massas
        %das regioes (blobs) maiores que minpix
        [cx, cy, radius, boundingbox, ndetect, ~,~ ,wframe_log] = extractnblobs(wframe, Imback, V, nanimais, mascara, minpix, maxpix, tol, avi, criavideo, tipsubfundo);
    
        %vetor que irá decorar cada animal que ja foi associado a um blob
        detectado = zeros(nanimais);
    
        if pxant(1) ~= 0 %global variable;

            if  tipfilt == 1
                %previsao do filtro de kalman
                for j=1:nanimais
                    pdecorada = [pxant(j); pyant(j)];
                    predita = A*[pdecorada;v(:,j)] + Bu;
                    %garantir que esta dentro da imagem
                    predita(1) = min(max(predita(1),1),c);
                    predita(2) = min(max(predita(2),1),l);
                    pxant(j) = predita(1);
                    pyant(j) = predita(2);
                    v(:,j) = predita(3:4);
                end
            end
            
        end
       
        %OLHAR POR PX E PY
        [px, py, detectado, caixa] = associateeuclid(nanimais, ndetect, pxant, pyant, cx, cy, radius, boundingbox, detectado, dicax, dicay ...
                                                     , caixa, l, c, frames_video(:,:,:,i));
    
        %aqui começa a parte que trata do cáculo das médias
        
        frameHSV = rgb2hsv(frames_video(:,:,:,i));  %converte o i-ésimo frame(frame atual) para HSV;
                   
        %OBS: Somente conseguimos dizer que o k-ésimo elemento do loop é o k-ésimo peixe em todas as situações porque antes de
        %rodar esse loop, as funções extractnblobs() e associateeuclid() fora executadas!
        
        %percorrendo de k=1 até o numero de animais (podemos ter mais de um blob por frame)
        for k=1:1:nanimais %blob individual do frame
            
            %variáveis para o tratamento da descontinuidade das cores no sistema HSV.
            amostrando = 1; %flag que garante uma pequena amostragem dos píxeis
            conta_amostrando = 0;
            quad14 = 0;
            quad23 = 0;
            quad_usado = 0;
            
            sizeOfBlob = 0; %number of pixels/blob;
            
            %PERCORRENDO A BOUNDING BOX
            m = floor(caixa(k, 2)); %reiniciando a coordenada m
            while m <= floor(caixa(k, 2) + caixa(k,4))
                
                n = floor(caixa(k, 1)); %reiniciando a coordenada n
                while n <= floor(caixa(k, 1) + caixa(k,3))
                    
                    if(detectado(k))
                        %detectado(:) é a condição em 0's e 1's de ter um peixe ou não associado ao k-ésimo blob(?) (VEM DO ASSOCIATEEUCLID() )                    
                        if(wframe_log(m,n) == 1 &&  frameHSV(m,n,2) >= 0.5 && frameHSV(m,n,3) >= 0.15)
                            %Amostrar alguns pixels, utilizar uma flag para selecionar os pixels e contamos quantos pixels pertencem a cada quadrante
                            %Após isso definiremos o espaço onde vamos trabalhar e resetamos o rastreio com o quadrante predominante
                            %Transformação T[h] = h - 1 
                            
                            if amostrando
                                conta_amostrando = conta_amostrando + 1;

                                if frameHSV(m,n,1) >= 0.25 && frameHSV(m,n,1) <= 0.75 %intervalo das cores
                                    quad23 = quad23 + 1;    %dois quadrantes do lado esquerdo (tons de verde e azul)
                                else 
                                    quad14 = quad14 + 1;    %dois quadrantes do lado direito (tons de vermelho e amarelo(?)
                                end
                                
                                %definindo com que quadrante trabalhar e resetando a flag
                                if conta_amostrando > 50
                                    amostrando = 0;
                                    
                                    if quad23 > quad14
                                        quad_usado = 23;
                                    else
                                        quad_usado = 14;
                                    end
                                        %voltamos para a execução normal do código
                                        m = floor(caixa(k, 2));
                                        n = floor(caixa(k, 1));
                                end
                                
                            else
                                pixel_hue = transformada_HSV( frameHSV(m,n,1), quad_usado);
                                mediaFrameIndividual = mediaFrameIndividual + pixel_hue;
                                sizeOfBlob = sizeOfBlob + 1;
                            end
                   
                        end
                    end
                    
                    n = n + 1; %incrementa a coordenada n
                
                end
                
                pxant = px;
                pyant = py;
                
                m = m + 1; %incrementa a coordenada m
            end
            
            %a média deve ser calculada depois de percorrer toda aquela bounding box para o k-ésimo animal
            mediaFrameIndividual =  mediaFrameIndividual/sizeOfBlob;
            mediaTOTAL(k, i) = mediaFrameIndividual; % (media do k-ésimo animal no i-ésimo frame)
            
            %zerando as variáveis de controle
            mediaFrameIndividual = 0;
            
        end

    end 
    
    %aloco previamente por questões de velocidade
    media = zeros(1, nanimais);
    variancia = zeros(1, nanimais);
    
    %cálculo dos outputs da função.
    for k=1:1:nanimais
        media(k) = nanmean(mediaTOTAL(k, 1:end));  %MEDIA FINAL CALCULADA: do primeiro ao último frame para o k-ésimo animal.
        variancia(k) = nanvar(mediaTOTAL(k, 1:end)); %VARIÂNCIA FINAL CALCULADA: do primeiro ao último frame para o k-ésimo animal.
    end
    
    %tratamento final
    for k=1:1:nanimais
       if media(k)>=0.25 && media(k)<=0.75 && media(k)<0
          media(k) = media(k) + 1; 
       end
    end
        
end

%Função para converter meu tempo inicial e final em termos dos frames correspondentes.
function [frame_inicial, frame_final] = extraiIntervaloFrames(tempo_inicial, tempo_final, video)
    frame_inicial = video.FrameRate*tempo_inicial;
    frame_final = video.FrameRate*tempo_final;  
end


function frames_video = geraVetor_frames_video(video, frame_inicial, frame_final)
%     frames_video = read(video, floor([frame_inicial frame_final]));   
    for i=frame_inicial:frame_final
        frames_video(i - frame_inicial + 1) = read(video, i);
    end
end


function H_novo = transformada_HSV(H, quadrante_usado)
    if quadrante_usado == 23
        H_novo = H;
    elseif quadrante_usado == 14
        if H >= 0.75
            H_novo = H - 1;
        else
            H_novo = H;       %se quadrante_usado == 14, então, aqui, necessariamente 0 <= H <= 0.25 (low-red)
        end
    end
end


function H_re_novo = transformadaInv_HSV(H, quadrante_usado)
    if quadrante_usado == 14 && H < 0
        H_re_novo = H + 1;
    else
        H_re_novo = H;
    end
        
end


%function [cc,cr,radius,boundingbox,ndetect,avi,foremm] = extractnblobs(Imwork,Imback,V,n,mascara,minpix,maxpix,tol,avi,criavideo,tipsubfundo)
%function [pxn,pyn,detectado,caixa] = associateeuclid(nanimais,ndetect,pxa,pya,cx,cy,radius,boundingbox,detectado,dicax,dicay,caixa,l,c,frame)

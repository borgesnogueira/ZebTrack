%Esta funcão é usada somente dentro do algoritmo de associação no momento
%em que se vai calcular a distância dentro de um espaço de cores. Para que
%isso aconteça, deve-se antes, calcular o valor da cor atual (média das
%cores dos pixeis.

%OBS:
%frame = frame do track.m;
%INTENSIDADE = intervalo que dita o valor do V de HSV, ou seja, dita o limite para que as cores sejam mais 'intensas';

function cor_atual = blob_colours(frame, l, c ...
                                  , cx, cy, radius, boundingbox, ndetect, wframe_log...
                                  , INTENSIDADE)
                                          

    %VARI�?VEIS DE CONTROLE DA FUNÇÃO: o vetor de cores atuais e a media das cores num frame
    cor_atual = zeros(1,ndetect); %vetor com quantidade de espaços correspondentes as cores de cada animal.
    mediaFrameIndividual = 0; %(Em 1 peixe e muda em cada loop).

    %aqui começa a parte que trata do cáculo das médias

    frameHSV = rgb2hsv(frame);  %converte o i-ésimo frame(frame atual) para HSV;

    %OBS: Somente conseguimos dizer que o k-ésimo elemento do loop é o k-ésimo peixe em todas as situações porque antes de
    %rodar esse loop, as funções extractnblobs() e associateeuclid() fora executadas!

    %percorrendo de k=1 até o numero de animais (podemos ter mais de um blob por frame)
    for k=1:1:ndetect %blob individual do frame
        
        
        
        %%%%%%%%%%%%%%%%%%%debuggando so debobs%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
%         debug_imagem = frame(floor(boundingbox(k, 2)):1:floor( boundingbox(k, 2) + boundingbox(k,4)), floor(boundingbox(k, 1)):1:floor(boundingbox(k, 1) + boundingbox(k,3) ), :);
        %%%%%%%%%%%%%%%%%%%debuggando so debobs%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%         
        
        
        
        
        %variáveis para o tratamento da descontinuidade das cores no sistema HSV.
        amostrando = 1; %flag que garante uma pequena amostragem dos píxeis
        conta_amostrando = 0;
        quad14 = 0;
        quad23 = 0;
        quad_usado = 0;

        sizeOfBlob = 0; %number of pixels/blob;
        
        
%         disp(['boundingbox:', num2str(boundingbox(k,:))]);
        
        
        %PERCORRENDO A BOUNDING BOX
        m = round(boundingbox(k, 2));
        m = max(m, 1); %reiniciando a coordenada m
        m = min(m, l);
        
        while m <= floor(boundingbox(k, 2) + boundingbox(k,4))
            
            n = round(boundingbox(k, 1));
            n = max(n, 1); %reiniciando a coordenada n
            n = min(n, c);
            
            while n <= floor(boundingbox(k, 1) + boundingbox(k,3))
%                     disp(['m = ', num2str(m), ';    n = ', num2str(n)])
                    
                    try 
                        %detectado(:) é a condição em 0's e 1's de ter um peixe ou não associado ao k-ésimo blob(?) (VEM DO ASSOCIATEEUCLID() )                    
                        controlando = wframe_log(m,n) == 1;
                    catch
                       disp(['m = ', num2str(), '; n = ', num2str(n)]) 
                    end
                    
                    if(controlando &&  frameHSV(m,n,2) >= 0.5 && frameHSV(m,n,3) >= 0.15)
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
                                m = round(boundingbox(k, 2));
                                m = max(m, 1); %reiniciando a coordenada m
                                m = min(m, l);
                                
                                n = round(boundingbox(k, 1));
                                n = max(n, 1); %reiniciando a coordenada n
                                n = min(n, c);
                            end

                        else
                            pixel_hue = transformada_HSV( frameHSV(m,n,1), quad_usado);
                         
                            %%%%%%%%%%%%%%%%%%%debuggando so debobs%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                            
%                             debug_imagem(m - floor(boundingbox(k,2)) + 1, n - floor(boundingbox(k,1)) + 1, 2) = 255;
                            %%%%%%%%%%%%%%%%%%%debuggando so debobs%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                            
                            
                            
                            %se meu pixel for um NaN, ao somar a mediaFrameIndividual ele transformara o valor contido em NaN, que não é o que queremos
                            if ~(isnan(pixel_hue))
                                mediaFrameIndividual = mediaFrameIndividual + pixel_hue;
                            end
                            
                            sizeOfBlob = sizeOfBlob + 1;
                        end

                    end
  

                n = n + 1; %incrementa a coordenada n
                n = int32(n);

            end
            
            m = m + 1; %incrementa a coordenada m
            m = int32(m);
            
        end
        
        
        %%%%%%%%%%%%%%%%%%%debuggando so debobs%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         figure, imshow(debug_imagem)
        %%%%%%%%%%%%%%%%%%%debuggando so debobs%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        
        
        
        %a média deve ser calculada depois de percorrer toda aquela bounding box para o k-ésimo animal
        mediaFrameIndividual =  mediaFrameIndividual/sizeOfBlob;
        cor_atual(k) = mediaFrameIndividual; % (media do k-ésimo animal no i-ésimo frame)
        
        %zerando as variáveis de controle
        mediaFrameIndividual = 0;
            
    end
    
           
    for k=1:1:ndetect
           if cor_atual(k)>=0.25 && cor_atual(k)<=0.75  || cor_atual(k)<0
              cor_atual(k) = cor_atual(k) + 1; 
           end
    %        disp(['------------ H(peixe ',num2str(k),') = ', num2str(cor_atual(k))])
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


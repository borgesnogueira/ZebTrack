%Esta func�o � usada somente dentro do algoritmo de associa��o no momento
%em que se vai calcular a dist�ncia dentro de um espa�o de cores. Para que
%isso aconte�a, deve-se antes, calcular o valor da cor atual (m�dia das
%cores dos pixeis.

%OBS:
%tol = threshrold na track.m, que serve para a subtra��o de fundo;
%Imback = wbackg do track.m;
%criavideo = criavideodiff do track.m;
%avi = aviobj2 do track.m (o input e n�o o output nessa fun��o!);
%wframe = working frame (double e em greyscale);
%frame = frame do track.m;
%INTENSIDADE = intervalo que dita o valor do V de HSV, ou seja, dita o limite para que as cores sejam mais 'intensas';
%V = Vrm do track.m;

function cor_atual = info_cores_frameAnterior(frame, Imback, V, nanimais, mascara, minpix, maxpix, tol, avi, criavideo, tipsubfundo ...
                                              , caixa, l, c ...
                                              , colorida, cor, tipfilt ...
                                              , INTENSIDADE)
                                          
        
    %vari�veis que preciso para o funcionamento do c�digo mas que n�o faz
    %sentido passar como par�metros.
    dicax = -1;
    dicay = -1;
    
    pxant = zeros(1,nanimais);
    pyant = zeros(1,nanimais);
                              
    %VARI�VEIS DE CONTROLE DA FUN��O: o vetor de cores atuais e a media das cores num frame
    cor_atual = zeros(nanimais); %vetor com quantidade de espa�os correspondentes as cores de cada animal.
    mediaFrameIndividual = 0; %(Em 1 peixe e muda em cada loop).

    %converte pra tons de cinza e double pra trabalhar
    if colorida || (cor == 1)
        wframe = double(frame);
    else
        wframe  = double(rgb2gray(frame));
    end


    %faz a diferenca so na area de interesse e extrai o centro de massas
    %das regioes (blobs) maiores que minpix
    [cx, cy, radius, boundingbox, ndetect, ~ , ~ , wframe_log] = extractnblobs(wframe, Imback, V, nanimais, mascara, minpix, maxpix, tol, avi, criavideo, tipsubfundo);

    %vetor que ir� decorar cada animal que ja foi associado a um blob
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
                                                 , caixa, l, c, frame);

    %aqui come�a a parte que trata do c�culo das m�dias

    frameHSV = rgb2hsv(frame);  %converte o i-�simo frame(frame atual) para HSV;

    %OBS: Somente conseguimos dizer que o k-�simo elemento do loop � o k-�simo peixe em todas as situa��es porque antes de
    %rodar esse loop, as fun��es extractnblobs() e associateeuclid() fora executadas!

    %percorrendo de k=1 at� o numero de animais (podemos ter mais de um blob por frame)
    for k=1:1:nanimais %blob individual do frame

        %vari�veis para o tratamento da descontinuidade das cores no sistema HSV.
        amostrando = 1; %flag que garante uma pequena amostragem dos p�xeis
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
                    %detectado(:) � a condi��o em 0's e 1's de ter um peixe ou n�o associado ao k-�simo blob(?) (VEM DO ASSOCIATEEUCLID() )                    
                    if(wframe_log(m,n) == 1 &&  frameHSV(m,n,2) >= 0.5 && frameHSV(m,n,3) >= 0.15)
                        %Amostrar alguns pixels, utilizar uma flag para selecionar os pixels e contamos quantos pixels pertencem a cada quadrante
                        %Ap�s isso definiremos o espa�o onde vamos trabalhar e resetamos o rastreio com o quadrante predominante
                        %Transforma��o T[h] = h - 1 

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
                                    %voltamos para a execu��o normal do c�digo
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
            
            m = m + 1; %incrementa a coordenada m
        end

        %a m�dia deve ser calculada depois de percorrer toda aquela bounding box para o k-�simo animal
        mediaFrameIndividual =  mediaFrameIndividual/sizeOfBlob;
        cor_atual(k) = mediaFrameIndividual; % (media do k-�simo animal no i-�simo frame)
        
        %zerando as vari�veis de controle
        mediaFrameIndividual = 0;
            
    end
        
    %tratamento final
    for k=1:1:nanimais
       if cor_atual(k)>=0.25 && cor_atual(k)<=0.75 && cor_atual(k)<0
          cor_atual(k) = cor_atual(k) + 1; 
       end
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %POTENCIAL PROBLEMA: acharmos como cor atual, Nan (ANALISAR DEPOIS)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end


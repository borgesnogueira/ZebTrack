%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Autor: Marcelo Borges Nogueira
%Data: 17/04/2013
%Descricao: Programa que faz o rastreamento de um ou mais animais a partir
%de imagens, e ao final informa varios dados relativos a
%posicao/velocidade dos animais
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%retornos (variaveis de saida):
%   t: vetor tempo (em segundos)
%   posicao: estrutura, com nanimais elementos, com campos x e y que
%           representam a posicao, em cm, de cada peixe em funcao do tempo
%           nos eixos x e y
%   velocidade: estrutura, com nanimais elementos, com campos x, y e total
%           que representam a velocidade de cada animal em funcao do tempo,
%           em cm/s, nos eixos x, y e velocidade total
%   parado: vetor com estrutura - tempo inicial, tempo final e
%           posicao inicial e final em que cada animal esteve parado
%   dormindo: vetor com estrutura - tempo inicial, tempo final e
%           posicao inicial e final em que cada animal esteve dormindo
%   tempoareas: matriz com estrutura - tempo inicial e tempo final em que
%           um certo animal esteve dentro de cada área informada na entrada
%   distperc: vetor com a distancia percorrida total de cada peixe (em cm)
%   comportamento: vetor com estrutura - tipo (codigo numerico) do comportamento atual,
%           tempo inicial, tempo final e posicao inicial e final de cada
%           peixe
%
%argumentos (variaveis de entrada):
%   mostraresnatela: dize se mostra o resultado na tela enquanto executa
%           0 -> nao mostra,  1 -> mostra
%   quadroini, quadrofim: numero dos quadros inicias e finais que deve ser
%           processados
%   fotos: caminho onde se encontra o  video e onde serao salbos os resultados.
%   video: objeto de video com o video do experimento
%   pixelcm: estrutura com campos x e y que informa a relação
%           pixel-centimetro (em pixels por centimetro)
%   nanimais: numero de animais que queremos detectar
%   procframe: processar 1 a cada procframe
%   corte: estrutura com campos xi,yi,xf,yf que especificam o retangulo no
%           qual sera feito o processamento para cortar a superficie do
%           aquario e outras areas com movimentos marginais (em pixels)
%   areas: vetor de estruturas xi,yi,xf,yf que definem areas de interesse (em
%           pixels)
%   areasexc: vetor de estruturas xi,yi,xf,yf que definem areas de exclusao (em
%           pixels)
%   viddiff: informa se vai criar o video com as imagens diferencas
%   thresh : o quanto cada pixel tem que mudar do fundo para se considerar
%           que houve movimento
%   filt: valor do filtro que depende da velocidade maxima do animal (valor
%           entre 0 -> filtragem maxima (animal nao mexe), e 1 -> sem filtragem)
%   handles: referencia para a janela grafica (para mostrar resultados do
%           tracking nela)
%   fundodinamico: indica se vamos utilizar fundo adaptativo
%   tipfilt: tipo de filtragem utilizada 0 -> media movel  1 -> kalman
%   tipsubfundo: tipo de subtracao de fundo 0 -> subtracao basica  1 ->
%           subtracao que leva em consideracao a estatistica (variancia) da imagem
%           de fundo criada
%   velmin: velocidade minima, em cm/s, para que um animal seja considerado parado
%   tempmin: tempo minimo, em segundos, para que um animal com velocidade
%           abaixo de velmin seja considerado parado
%   tempminparado: tempo mínimo parado, em segundos, para que seja
%           considerado que esta dormindo
%   subcor: usar imagem colorida na subtracao de fundo: 0 -> imagem tons de
%           cinza  1 -> imagem colorida
%   cameralenta: indica, em segundos, o valor de pausa entre a exibição de
%           cada processamento
%   trackmouse: indica se o programa ira apenas rastrear o mouse
%   
%   liveTracking: faz o rastreamento a partir de imagens obtidas de uma
%   webcam
%   trackindividuals: utiliza um banco de features para idendificar cada
%   animal no caso de rastreamento 
%   actions: conjunto de ações para envio para hardware externo
%   pinicial: posição inicial do peixe




function [t,posicao,velocidade,parado,dormindo,tempoareas,distperc,comportamento] = track(mostraresnatela,quadroini,quadrofim,fotos,video,pixelcm,nanimais,procframe...
    ,corte,areas,areasexc,criavideores,viddiff,thresh,filt,handles,fundodinamico,tipfilt,tipsubfundo,velmin,tempmin,tempminparado,subcor,cameralenta,trackmouse,liveTracking,trackindividuals,actions,pinicial)

    %CONSTANTES A SEREM AJUSTADAS:

    %define o TAMANHO MINIMO e MAXIMO, em pixeis, de uma área para ser considerada
    %um animal
    minpix = 2;
    maxpix = 0; %se o tamanho maximo for zero, fica sendo 50% da imagem

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Informa se queremos trabalhar com a imagem colodira ou em tons de cinza
    %1 - > colorida     0-> tons de cinza
    colorida = subcor;

    %VELOCIDADE MINIMA abaixo da qual consideramos que o animal esta PARADO
    %Valor em cm/s
    vmin = velmin;

    %TEMPO MINIMO, em segundos, para se considerar que um animal ficou PARADO
    tmin = tempmin;

    %TEMPO, em segundos, que o animal tem que ficar PARADO para se considerar que DORMIU
    tminparado = tempminparado;



    %threshold adaptativo
    global threshadaptativo;

    %variavel global para informar o frame atual para o gui
    global  numframeatual;

    if ~exist('nanimais','var')
        nanimais=1;
    end

    if ~exist('procframe','var')
        procframe=1;
    end

    if exist('thresh','var')
        threshold = thresh;
    else
        threshold = 10;
    end

    if exist('filt','var')
        alpha = filt;
    else
        alpha = 0.6;
    end

    if exist('viddiff','var')
        criavideodiff = viddiff;
    else
        criavideodiff = 0;
    end

    if ~exist('fundodinamico','var')
        fundodinamico = false;
    end

    if ~exist('tipfilt','var')
        tipfilt = 0;
    end

    if ~exist('liveTracking','var')
        liveTracking = 0;
    end

    if ~exist('trackindividuals','var')
        trackindividuals = 0;
    end
    V = zeros(handles.l,handles.c);
    %numero de QUADROS por SEGUNDO do video
    if liveTracking
        fps = 1;
        tipsubfundo=0;
        V = handles.V;
    else
        fps = video.FrameRate;
    end

    global abort
    if isempty(abort)
        abort = 0;
    end

    global pausar
    if isempty(pausar)
        pausar = 0;
    end

    global dicax
    if isempty(dicax)
        dicax = -1;
    end
    global dicay
    if isempty(dicay)
        dicay = -1;
    end

    global tecla
    if isempty(tecla)
        tecla = 0;
    end

    global apertada
    if isempty(apertada)
        apertada = 0;
    end

    %for trackmouse
    global pmousex;
    global pmousey;
    pmousex=-1;
    pmousey=-1;

    %ajusta o alpha de acordo com o procframe
    %     if tipfilt == 0
    %         novoalpha = 0;
    %         for i=1:procframe
    %            novoalpha = novoalpha + (-1)^(i-1)*alpha^i*calctermoserie(procframe,i);
    %         end
    %         alpha = novoalpha/procframe;
    %     end
    %

    %carrega a imagem de fundo
    if ~liveTracking
        backg = imread([fotos,'/',handles.filenameSemExtensao,'.jpeg']);
        %carrega varicancia da imagem de fundo (variavel V)
        load([fotos,'/',handles.filenameSemExtensao,'V.mat']);
    else
        backg = imread('./live/live.jpeg');
    end

    [l,c,cor] = size(backg);    %Pegando as dimensões do meu fundo.

    if colorida || (cor == 1)
        wbackg = double(backg);
    else
        wbackg = double(rgb2gray(backg));
    end

    %vetor com cores
    vcores = [0 0 1; 1 0 0; 0 1 0; 1 1 1; 1 1 0; 1 0 1; 0 1 1];

    if criavideores
        %aviobj = avifile([fotos,'/result.avi'],'fps',fps*1/procframe);
        aviobj = VideoWriter([fotos,'/',handles.filenameSemExtensao,'result.avi']);
        aviobj.FrameRate = fps*1/procframe;
        open(aviobj);
    end

    %pega o tamanho da tela
    tela = get(0,'ScreenSize');

    %seta o tamanho das figura que irao aparecer
    xifig = min(c,tela(3)/2)+1;
    yifig = max(tela(4)-l-50,1);
    txfig = min(c,tela(3)/2);
    tyfig = min(l,tela(4)-200);

    iptsetpref('ImshowBorder','tight'); %remover bordas
    figvid = figure(5);
    set(figvid,'units','pix');
    set(figvid,'position',[xifig yifig  txfig tyfig]);
    if (~mostraresnatela) || exist('handles','var')
        set(figvid,'Visible', 'off');
    end

    if criavideodiff
        %aviobj2 = avifile([fotos,'/resultdiff.avi'],'fps',fps*1/procframe);
        aviobj2 = VideoWriter([fotos,'/',handles.filenameSemExtensao,'resultdiff.avi']);
        aviobj2.FrameRate = fps*1/procframe;
        open(aviobj2);
        %figvideodiff = figure(6);
        %set(figvideodiff,'units','pix');
        %set(figvideodiff,'position',[1 yifig min(2*c,tela(3)-1) min(l,tela(4)-201)]);
    else
        aviobj2=0;
        figvideodiff=0;
    end


    quadroini = floor(quadroini);
    %gera o vetor tempo, iniciando no tempo inicial da rastreio
    t = 1/fps*(quadroini-1:procframe:quadrofim-1);

    %aloca espaço para px e py para aumentar velocidade
    global px;
    global py;
    px=zeros(nanimais,floor((quadrofim-quadroini)/procframe));
    py=zeros(nanimais,floor((quadrofim-quadroini)/procframe));

    %indica se um animal esta parado no momento
    indparado = zeros(nanimais);
    %indica se um animal esta dormindo no momento
    inddormindo = zeros(nanimais);
    %variaveis que servem pra contar quantas vezes cada animal ficou parado e dormindo
    contparado = zeros(nanimais);
    contdormindo = zeros(nanimais);

    parado={};
    dormindo = {};
    for j=1:nanimais
        parado{j}.ti(1)=0;
        parado{j}.tf(1)=0;
        parado{j}.xi(1)=1;
        parado{j}.yi(1)=1;
        parado{j}.xf(1)=1;
        parado{j}.yf(1)=1;

        dormindo{j}.xi(1) = 1;
        dormindo{j}.yi(1) = 1;
        dormindo{j}.ti(1) = 0;
        dormindo{j}.xf(1) = 1;
        dormindo{j}.yf(1) = 1;
        dormindo{j}.tf(1) = 0;
    end


    tempoareas = {};
    if exist('areas','var')
        nareas = length(areas); %numero de areas passadas pelo usuario
        dentroarea = zeros(nanimais,nareas); %se cada animal esta dentro ou fora de cada area
        contareas = zeros(nanimais,nareas); %numero de vezes que cada animal entrou e saiu de uma area
    else
        nareas = 0;
    end

    %para que todas as areas aparecam na resp, colocar que todos os peixes
    %entraram e sairam no temop zero em cada uma
    for i=1:nanimais
        for j=1:nareas
            tempoareas{i,j}.ti = 0;
            tempoareas{i,j}.tf = 0;
        end
    end

    comportamento = {}; %cria variavel pra nao haver erros
    contcomportamento = 0;
    vetorletras = ['q' 'w' 'e' 'r' 't' 'y' 'u' 'i' 'o' 'p' 'a' 's' 'd' 'f' 'g' 'h' 'j' 'k' 'l'];

    if ~exist('areasexc', 'var')
        areasexc = [];
    end
    nareasexc = length(areasexc);

    distperc = zeros(1,nanimais); %distancia percorrida por cada animal
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % listagem de passagem por areas
    % por mtxslv
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if tipfilt == 1
        % Kalman filter para cada animal
        R = [[5 ,0]',[0,5]']; %erro na medicao em pixels: no maximo 3*sqrt(var) pixels
        H = [[1,0]',[0,1]',[0,0]',[0,0]'];
        Q = 0.1*filt*eye(4); %erro do processo
        dt = fps/procframe; %pixels/time step
        A = [[1,0,0,0]',[0,1,0,0]',[dt,0,1,0]',[0,dt,0,1]']; %modelo com posicao x e y e velocidade constante dx e dy
        Bu = [0,0,0,0]'; %velocidade constante. se fosse algo caindo seria Bu = [0,0,0,g]' (positivo pq y aumenta pra baixo)
        %na hora da filtragem eu freio o animal para que, caso nao seja detectado por
        %um certo tempo, nao saia da area da figura
        %Bu(3:4) = -.25*v(:,j);
        P = zeros(4,4,nanimais);
        for j=1:nanimais
            P(:,:,j) = 100*eye(4); %incerteza inicial alta
        end
        v = zeros(2,nanimais);
    end

    %calcular a mascara
    mascara = calculamascara(corte,areasexc,wbackg);


    global cont;
    cont = 1;

    Vrm =  V.^.5;
    %garante que todo mundo em Vrm eh no mínimo 0.5
    Vrm(Vrm<0.5) = 0.5;


    i=quadroini;
    %for i=quadroini:procframe:quadrofim

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %TESTES DE ARIEL
    if(trackindividuals)
        INTENSO = 0.4;

    %     testados:
    %     539 inicial e 544 final
    %     inicial 325 e final 327
    %     inicial 678 e final 679
    %     inicial 685 e final 679
        tempo_inicial = 168;
        tempo_final = 169;

        if ~exist('caixa','var')    %não tenho a mínima ideia de onde a caixa possa vir a ter surgido.
            caixa = ones(nanimais,4);
        end

        [media, variancia] = calculaMediaVarianciaHSV(video, tempo_inicial, tempo_final ...
                                                   , wbackg, Vrm, nanimais, mascara, minpix, maxpix, threshold, aviobj2, criavideodiff, tipsubfundo ...
                                                   , caixa, l, c ...
                                                   , colorida, cor, tipfilt ...
                                                   , INTENSO);
       %gerando uma figura com a cor variando com sua variancia.
       mostra_cores_dos_peixes(media, variancia);

    end
    %FIM DOS TESTES DE ARIEL
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


    if liveTracking
        videoLive = videoinput('winvideo');
        triggerconfig(videoLive, 'manual');
        %cria um objeto videoinput, com o adptador e formatos suportados pelo
        %hardware da maquina onde serÃ¡ executado o programa
        src = getselectedsource(videoLive);
        %videoLive.FramesPerTrigger = 300;
        %definiÃ§Ã£o da quantidade de frames capturados para gerar o video que
        %serÃ¡ usado para criaÃ§Ã£o do fundo
        start(videoLive);
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %comandos para hadware externo
    if actions.nactions>0
        %fecha todas as abertas atualmente
        fclose(instrfind);
        %conecta na porta serial
        serialcom = serial(actions.serialport, 'BaudRate',actions.serialspeed);
        try
            fopen(serialcom);
        catch
            disp('Could not connect to serial device');
        end
    end

    ti=tic;
    while i<=quadrofim
        
        %disp(['frame atual: ', num2str(i)])

        %variavel global para informar o frame atual para o gui
        numframeatual = i;
        %frame = imread([fotos,'/frame',int2str(i), '.jpeg']);

        if(liveTracking)
           frame = getsnapshot(videoLive);
           t(cont)=toc(ti);
        else
           frame = read(video,floor(i));
        end

        if pmousex==-1 && pmousey==-1

            %converte pra tons de cinza e double pra trabalhar
            if colorida || (cor == 1)
                wframe = double(frame);
            else
                wframe = double(rgb2gray(frame));
            end


            %faz a diferenca so na area de interesse e extrai o centro de massas
            %das regioes (blobs) maiores que minpix
            [cx,cy,radius,boundingbox,ndetect,aviobj2,imdif] = extractnblobs(wframe,wbackg,Vrm,nanimais,mascara,minpix,maxpix,threshold,aviobj2,criavideodiff,tipsubfundo);

            if threshadaptativo
                if ndetect < nanimais && threshold > 2 %ficara no minimo com 2
                    threshold = threshold - 1;
                    if ndetect == 1 %evita achar um blob gigante que ocupa mais da metade da imagem
                        if radius(1)^2*pi < l*c/2
                            threshold = threshold + 5;
                        end
                    end
                elseif ndetect > nanimais && threshold < 50
                    threshold = threshold + 1;
                end
                %mostra na barra de trheshold no ambiente grafico
                set(handles.slider3,'Value',threshold);
                set(handles.threshold,'String',num2str(threshold));

            else
                %pega o valor em tempo real
                threshold = round(get(handles.slider3,'Value'));
            end

        end


        %vetor que irá decorar cada animal que ja foi associado a um blob
        detectado=zeros(1,nanimais);



        if cont >1

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


            if(trackindividuals)
                %adicionaremos associatefudera depois!
                vetor_cores_atuais = blob_colours(frame, l, c, ...
                                                  cx, cy, radius, boundingbox, ndetect, imdif, ...
                                                  INTENSO);
                
                %definindo um valor para alpha:
                alpha_distancia = 0;    %20% para a distância euclidiana e 80% para a distância no espaço de cores.
                
                [px(:,cont),py(:,cont),detectado,caixa] = associatefudera(nanimais, ndetect, px(:,cont-1), py(:,cont-1), cx, cy, radius,...
                                                                          boundingbox, detectado, dicax, dicay, caixa, l, c, frame, ...
                                                                          vetor_cores_atuais, media, variancia, ...
                                                                          alpha_distancia);

            else
                [px(:,cont) ,py(:,cont), detectado, caixa] = associateeuclid(nanimais, ndetect, px(:,cont-1), py(:,cont-1), cx, cy, radius, ...
                                                                             boundingbox, detectado, dicax, dicay, ...
                                                                             caixa, l, c, frame);
            end

            %zera as dicas
            dicax = -1;
            dicay = -1;

            %salva as imagens e mascaras dos peixes achados
            %              for j=1:nanimais
            %                     xi = round(max(1,caixa(j,1) - 3));
            %                     yi = round(max(1,caixa(j,2) - 3));
            %                     xf = round(min(caixa(j,1) + caixa(j,3) + 3,c));
            %                     yf = round(min(caixa(j,2) + caixa(j,4) + 3,l));
            %                     imwrite(frame(yi:yf,xi:xf,:),fullfile(handles.directoryname,['a' num2str(j) 'f' num2str(cont) '.png']));
            %                     imwrite(uint8(255*imdif(yi:yf,xi:xf,:)),fullfile(handles.directoryname,['a' num2str(j) 'm' num2str(cont) '.png']));
            %              end



            %filtragem das posicoes
            for k=1:nanimais
                if tipfilt == 0
                    %média móvel
                    px(k,cont)=alpha*px(k,cont) + (1-alpha)*px(k,cont-1);
                    py(k,cont)=alpha*py(k,cont) + (1-alpha)*py(k,cont-1);
                end
                if tipfilt == 1
                    %kalman
                    PP(:,:,j) = A*P(:,:,j)*A' + Q;
                    K = PP(:,:,j)*H'*inv(H*PP(:,:,j)*H'+R);
                    filtrada = (predita + K*([px(j,cont),py(j,cont)]' - H*predita))'; %erro [cc(i),cr(i)]' - H*xp
                    P(:,:,j) = (eye(4)-K*H)*PP(:,:,j);
                    px(j,cont) = filtrada(1);
                    py(j,cont) = filtrada(2);
                    v(:,j) = filtrada(3:4);
                    %devolve valores da posicao passada, que antes estavam
                    %com as posicoes previstas
                    px(j,cont-1) = pdecorada(1);
                    py(j,cont-1) = pdecorada(2);
                    %freia o animal para que, caso nao seja detectado por
                    %um certo tempo, nao saia da area da figura
                    Bu(3:4) = -.25*v(:,j);
                end
            end


            if apertada
                areaescolhida = str2num(tecla);
                if ~ isnan(areaescolhida)
                    if areaescolhida<=nareas %nao foi letra nem um numero de areas que nao existe
                        %centro de massa
                        tx = mean(areas(areaescolhida).x);
                        ty = mean(areas(areaescolhida).y);
                        if ~inpolygon(tx,ty,areas(areaescolhida).x,areas(areaescolhida).y) %se nao estiver dentro, pega na borda
                            tx = mean(areas(areaescolhida).x(1:2));
                            ty = mean(areas(areaescolhida).y(1:2));
                        end

                        px(1,cont) = tx;
                        py(1,cont) = ty;
                    end
                else
                    %procura qual letra foi
                    for indletra = 1:length(vetorletras)
                        if tecla == vetorletras(indletra)
                            %testa se é diferente do comportamento atual
                            if comportamento.tipo(contcomportamento) ~= indletra %novo comportamento
                                %fecha comportamento atual
                                comportamento.tf(contcomportamento) = t(cont-1);
                                comportamento.xf(:,contcomportamento) = px(:,cont-1)/pixelcm.x;
                                comportamento.yf(:,contcomportamento) =(l-py(:,cont-1))/pixelcm.y;
                                %abre novo comportamento
                                contcomportamento = contcomportamento + 1;
                                comportamento.tipo(contcomportamento) = indletra;
                                comportamento.ti(contcomportamento) = t(cont-1);
                                comportamento.xi(:,contcomportamento) = px(:,cont-1)/pixelcm.x;
                                comportamento.yi(:,contcomportamento) =(l-py(:,cont-1))/pixelcm.y;
                            end

                        end
                    end
                end
            end

            if trackmouse && pmousex~=-1 && pmousey~=-1
                px(1,cont) = pmousex;
                py(1,cont) = pmousey;
            end

            %ajeita as caixas para as posicoes filtradas
            for j=1:nanimais
                caixa(j,1:4) = [px(j,cont)-round(caixa(j,3)/2) py(j,cont)-round(caixa(j,4)/2) caixa(j,3) caixa(j,4)];
            end


        else %primeira iteracao
            %se tiver recebido a posicao inicial dos animais, simplesmente
            %atribui elas
            if exist('pinicial','var')
                if length(pinicial.x)==nanimais
                    px(:,cont)=pinicial.x;
                    py(:,cont)=pinicial.y;
                    for j=1:nanimais
                        detectado(j)=1;
                        caixa(j,1:4) = [px(j,cont)-10 py(j,cont)-10 20 20];
                    end
                else
                    %escolhe os animais na ordem em que foram ordenados os blobs
                    for j=1:min(ndetect,nanimais)
                        px(j,cont)=round(cx(j));
                        py(j,cont)=round(cy(j));
                        %marca que tal animal foi detectado nesta iteracao
                        detectado(j)=1;
                        caixa(j,1:4) = boundingbox(j,:);
                    end
                    %procura animais nao detectados na primeira iteracao
                    for j=ndetect+1:nanimais
                        %bota o animal pra iniciar nomeio da imagem
                        px(j,cont)=round(c/2);
                        py(j,cont)=round(l/2);
                        detectado(j)=1;
                        caixa(j,1:4) = [px(j,cont)-10 py(j,cont)-10 20 20];
                    end
                end
            else
                %escolhe os animais na ordem em que foram ordenados os blobs
                for j=1:min(ndetect,nanimais)
                    px(j,cont)=round(cx(j));
                    py(j,cont)=round(cy(j));
                    %marca que tal animal foi detectado nesta iteracao
                    detectado(j)=1;
                    caixa(j,1:4) = boundingbox(j,:);
                end
                %procura animais nao detectados na primeira iteracao
                for j=ndetect+1:nanimais
                    %bota o animal pra iniciar nomeio da imagem
                    px(j,cont)=round(c/2);
                    py(j,cont)=round(l/2);
                    detectado(j)=1;
                    caixa(j,1:4) = [px(j,cont)-10 py(j,cont)-10 20 20];
                end
            end
            comportamento.tipo(1) = 1; %inicia no comportamento numero 1
            comportamento.ti(1) = t(cont);
            comportamento.xi(:,1) = px(:,cont)/pixelcm.x; %posicoes dos animais
            comportamento.yi(:,1) =(l-py(:,cont))/pixelcm.y;
            contcomportamento = 1;
        end




        for j=1:nanimais
            %determina se o animal esta parado
            if cont >1 %&& detectado(j) %se o animal foi detectado
                vp = sqrt(((px(j,cont)  - px(j,cont-1))/pixelcm.x)^2 + ((py(j,cont) - py(j,cont-1))/pixelcm.y)^2)*fps/procframe;
                if vp < vmin  %velocida menor que a minima
                    pa = 1;
                else
                    pa = 0;
                end
            else
                pa=0;
            end

            %se nao estava parado e agora parou
            if(~indparado(j) && pa)
                contparado(j) = contparado(j)+1;
                indparado(j) = 1;
                parado{j}.ti(contparado(j)) = t(cont);
                parado{j}.xi(contparado(j)) = px(j,cont)/pixelcm.x;
                parado{j}.yi(contparado(j)) = (l-py(j,cont))/pixelcm.y;
            end

            %teste se já esta mai de tminparado segundos parado, pra mudar
            %a cor do plot
            if indparado(j)
                if t(cont) - parado{j}.ti(contparado(j)) > tminparado
                    inddormindo(j)=1;
                end
            end

            %se estava parado e agora comecou a mexer
            if(indparado(j) && ~pa)
                indparado(j)=0;
                inddormindo(j)=0;
                parado{j}.tf(contparado(j)) = t(cont);
                parado{j}.xf(contparado(j)) = px(j,cont)/pixelcm.x;
                parado{j}.yf(contparado(j)) = (l-py(j,cont))/pixelcm.y;
                %se o animal ficou parado menos tempo que tempmin, eh
                %desconsiderado
                if parado{j}.tf(contparado(j)) - parado{j}.ti(contparado(j)) < tmin

                    if contparado(j) == 1
                        parado{j}.ti(1)=0;
                        parado{j}.tf(1)=0;
                        parado{j}.xi(1)=1;
                        parado{j}.yi(1)=1;
                        parado{j}.xf(1)=1;
                        parado{j}.yf(1)=1;
                    else
                        parado{j}.ti(contparado(j)) = [];
                        parado{j}.xi(contparado(j)) = [];
                        parado{j}.yi(contparado(j)) = [];
                        parado{j}.tf(contparado(j)) = [];
                        parado{j}.xf(contparado(j)) = [];
                        parado{j}.yf(contparado(j)) = [];
                    end
                    contparado(j)=contparado(j)-1;
                else

                    %testa se ficou tempo suficiente parado pra se considerar
                    %que o animal dormiu
                    if parado{j}.tf(contparado(j)) - parado{j}.ti(contparado(j)) < tminparado
                        %copia para e estrutura parado para a estrutura
                        %dormindo
                        contdormindo(j) = contdormindo(j) + 1;
                        dormindo{j}.xi(contdormindo(j)) = parado{j}.xi(contparado(j));
                        dormindo{j}.yi(contdormindo(j)) = parado{j}.yi(contparado(j));
                        dormindo{j}.ti(contdormindo(j)) = parado{j}.ti(contparado(j));
                        dormindo{j}.xf(contdormindo(j)) = parado{j}.xf(contparado(j));
                        dormindo{j}.yf(contdormindo(j)) = parado{j}.yf(contparado(j));
                        dormindo{j}.tf(contdormindo(j)) = parado{j}.tf(contparado(j));
                    end
                end
            end
        end

        %testa, para cada area, se cada animal esta dentro
        alguemdentro = zeros(1,nareas);
        for k=1:nareas
            for j=1:nanimais
                %if(px(j,cont)>= areas(k).xi && px(j,cont)<= areas(k).xf && py(j,cont)>= areas(k).yi && py(j,cont)<= areas(k).yf)
                if inpolygon(px(j,cont),py(j,cont),areas(k).x,areas(k).y)
                    dentro = 1;
                    alguemdentro(k)=1;
                     factions(3,k,j,actions,serialcom);
                else
                    dentro = 0;
                    factions(4,k,j,actions,serialcom);
                end
                %se estava fora e entrou agora
                if ~dentroarea(j,k) && dentro
                    dentroarea(j,k) = 1;
                    contareas(j,k) = contareas(j,k) + 1;
                    tempoareas{j,k}.ti(contareas(j,k)) = t(cont);
                    factions(1,k,j,actions,serialcom);
                end

                %se estava dentro e saiu agora
                if dentroarea(j,k) && ~dentro
                    dentroarea(j,k) = 0;
                    tempoareas{j,k}.tf(contareas(j,k)) = t(cont);
                    factions(2,k,j,actions,serialcom);
                end
            end
        end



        %para acelerar o funcionamento, so mostra na tela de tempos em
        %tempos
        if rem(cont,round(get(handles.slider11,'Value'))) == 0

            if criavideores

                set(0,'CurrentFigure',figvid); %seta com atual sem mostrar

                %desenha as localizacoes dos animais
                hold off
                imshow(frame);
                hold on

                for j=1:nanimais
                    xi = max(1,caixa(j,1) - 3);
                    yi = max(1,caixa(j,2) - 3);
                    xf = min(caixa(j,1) + caixa(j,3) + 3,c);
                    yf = min(caixa(j,2) + caixa(j,4) + 3,l);
                    if indparado(j) && ~inddormindo(j)
                        numer = (t(cont) - parado{j}.ti(contparado(j)));
                        denom = tmin;
                        line([xi xf xf xi xi],[yi yi yf yf yi],'Color',max((1 - numer/denom),0)*vcores(mod(j,7)+1,:));
                    else
                        if inddormindo(j)
                            line([xi xf xf xi xi],[yi yi yf yf yi],'Color',[1 0.6 0]);
                        else
                            line([xi xf xf xi xi],[yi yi yf yf yi],'Color',vcores(mod(j,7)+1,:));
                        end
                    end
                    text(xi+2,yi+7,num2str(j),'FontSize',11,'Color',vcores(mod(j,7)+1,:));
                end

                for k=1:nareas
                    %desenha as areas mudando a cor se tiver alguem dentro
                    if(alguemdentro(k)==1)
                        desenha_areas(areas(k),'','w',k);
                    else
                        desenha_areas(areas(k),'','b',k);
                    end
                end

                %warning ('off','all');
                %frameavi = im2frame(zbuffer_cdata(figvid)); %pega e o frame fica invisivel. em breve nao sera mais suportado
                %warning ('on','all');

                frameavi = print(figvid,'-RGBImage'); %jeito novo (2015a) (mais lento)

                %adiciona o frame ao video
                writeVideo(aviobj,frameavi);

            end

            %plota no GUI
            if exist('handles','var') && mostraresnatela
                set(0,'CurrentFigure',handles.figure1);
                set(handles.figure1,'CurrentAxes',handles.axes4);
                hold off
                imhandle = imshow(frame);
                set(imhandle,'ButtonDownFcn',@clickfigura );
                hold on

                for j=1:nanimais
                    xi = max(1,caixa(j,1) - 3);
                    yi = max(1,caixa(j,2) - 3);
                    xf = min(caixa(j,1) + caixa(j,3) + 3,c);
                    yf = min(caixa(j,2) + caixa(j,4) + 3,l);
                    if indparado(j) && ~inddormindo(j)
                        numer = (t(cont) - parado{j}.ti(contparado(j)));
                        denom = tmin;
                        phandle = line([xi xf xf xi xi],[yi yi yf yf yi],'Color',max((1 - numer/denom),0)*vcores(mod(j,7)+1,:));
                        set(phandle,'ButtonDownFcn',@clickfigura );
                    else
                        if inddormindo(j)
                            phandle = line([xi xf xf xi xi],[yi yi yf yf yi],'Color',[1 0.6 0]);
                            set(phandle,'ButtonDownFcn',@clickfigura );
                        else
                            phandle = line([xi xf xf xi xi],[yi yi yf yf yi],'Color',vcores(mod(j,7)+1,:));
                            set(phandle,'ButtonDownFcn',@clickfigura );
                        end
                    end
                    thandle = text(xi+2,yi+7,num2str(j),'FontSize',11,'Color',vcores(mod(j,7)+1,:));
                    set(thandle,'ButtonDownFcn',@clickfigura );
                end
                %areas de interesse
                for k=1:nareas
                    %desenha as areas mudando a cor se tiver alguem dentro
                    if(alguemdentro(k)==1)
                        desenha_areas(areas(k),@clickfigura,'w',k);
                    else
                        desenha_areas(areas(k),@clickfigura,'b',k);
                    end

                end
                %areas de exclusao
                desenha_areas(areasexc,@clickfigura,'r',-1);


                %plota rastro (os ultimos pontos onde o peixe foi
                %detectado)
                global nulitimospontos;
                if(nulitimospontos ~= 0)
                    plot(px(1,max(cont-nulitimospontos,1):cont),py(1,max(cont-nulitimospontos,1):cont),'o');
                    plot(px(1,max(cont-nulitimospontos,1):cont),py(1,max(cont-nulitimospontos,1):cont));
                end

                %                 if criavideores
                %                     frameavi = getframe(handles.axes4);
                %                     %adiciona o frame ao video
                %                     writeVideo(aviobj,frameavi);
                %                 end

            end

            if ~liveTracking
                set(handles.tamin,'String',num2str(floor((numframeatual)/(handles.video.Framerate*60))));
                set(handles.taseg,'String',num2str(floor((numframeatual)/(handles.video.Framerate) - 60*floor((numframeatual)/(handles.video.Framerate*60)))));
            end

            if cameralenta>0
                pause(cameralenta)
            end

        end

        %estima tempo que ainda falta para terminar
        if mod(cont,10) == 5
            tf=toc(ti);
            tgasto=tf/60; %em minutos
            if liveTracking
                set(handles.tgasto,'String',num2str(tgasto,2));
            else
                tmedio=tf/(cont*60);
                trestante=tmedio*((quadrofim-quadroini)/procframe-cont);
                %mostra no gui
                if exist('handles','var')
                    set(handles.trest,'String',num2str(trestante,2));
                    set(handles.tgasto,'String',num2str(tgasto,2));
                    handles.waibar.setvalue(tgasto/(trestante+tgasto));
                else
                    disp(['Tempo gasto: ' num2str(tgasto) ' minutos. Tempo restante: ' num2str(trestante) ' minutos'])
                end
            end

        end
        drawnow
        %calculo do fundo dinamico
        if fundodinamico
            filtrofundo1 = 0.99;
            filtrofundo2 = 0.95;

            %atualiza o fundo nas regioes em que nao tem animais detectados
            for j=1:nanimais
                xi = max(1,round(caixa(j,1) - 10));
                yi = max(1,round(caixa(j,2) - 10));
                xf = min(round(caixa(j,1) + caixa(j,3) + 10),c);
                yf = min(round(caixa(j,2) + caixa(j,4) + 10),l);
                %figure(7)
                %imshow(uint8(wframe(yi:yf,xi:xf)))
                wframe(yi:yf,xi:xf) = filtrofundo2*wbackg(yi:yf,xi:xf) + (1-filtrofundo2)*wframe(yi:yf,xi:xf);
            end
            %atualiza variancia de acordo com a formula em http://en.wikipedia.org/wiki/Algorithms_for_calculating_variance
            %vamos supor sempre que estamos adicionando o 100 frame ao conjutno
            if ~colorida 
                medianova = wbackg + (wframe - wbackg)/100;
                V(:,:,4) = (99*V(:,:,4) + (wframe - wbackg).*(wframe - medianova))/100;
            end
            %calcula novo fundo
            wbackg = filtrofundo1*wbackg + (1-filtrofundo1)*wframe;
            Vrm =  V.^.5;

        end

        while pausar
            pause(0.2)
        end

        cont = cont+1;

        if abort
            px = px(:,1:cont-1);
            py = py(:,1:cont-1);
            t = t(1:cont-1);
            break;
        end

        i = i + procframe;  

        if liveTracking
            quadrofim=i+1;
        end
    end

    if liveTracking
        delete(videoLive);
    end
    fclose(serialcom);

    %verifica se tinha gente parado que ficou parado até o final do
    %rastreamento
    for j=1:nanimais
        %se terminou o rastreamento e continua parado
        if(indparado(j))
            indparado(j)=0;
            parado{j}.tf(contparado(j)) = t(cont-1);
            parado{j}.xf(contparado(j)) = px(j,cont-1);
            parado{j}.yf(contparado(j)) = py(j,cont-1);
            %se o animal ficou parado menos tempo que tempmin, eh
            %desconsiderado
            if parado{j}.tf(contparado(j)) - parado{j}.ti(contparado(j)) < tmin
                if contparado(j) == 1
                    parado{j}.ti(1)=0;
                    parado{j}.tf(1)=0;
                    parado{j}.xi(1)=1;
                    parado{j}.yi(1)=1;
                    parado{j}.xf(1)=1;
                    parado{j}.yf(1)=1;
                else
                    parado{j}.ti(contparado(j)) = [];
                    parado{j}.xi(contparado(j)) = [];
                    parado{j}.yi(contparado(j)) = [];
                    parado{j}.tf(contparado(j)) = [];
                    parado{j}.xf(contparado(j)) = [];
                    parado{j}.yf(contparado(j)) = [];
                    contparado(j)=contparado(j)-1;
                end
            else
                %testa se ficou tempo suficiente parado pra se considerar
                %que o animal dormiu
                if parado{j}.tf(contparado(j)) - parado{j}.ti(contparado(j)) < tminparado
                    %copia para e estrutura parado para a estrutura
                    %dormindo
                    contdormindo(j) = contdormindo(j) + 1;
                    dormindo{j}.xi(contdormindo(j)) = parado{j}.xi(contparado(j));
                    dormindo{j}.yi(contdormindo(j)) = parado{j}.yi(contparado(j));
                    dormindo{j}.ti(contdormindo(j)) = parado{j}.ti(contparado(j));
                    dormindo{j}.xf(contdormindo(j)) = parado{j}.xf(contparado(j));
                    dormindo{j}.yf(contdormindo(j)) = parado{j}.yf(contparado(j));
                    dormindo{j}.tf(contdormindo(j)) = parado{j}.tf(contparado(j));
                end
            end
        end
    end

    %acabou o rastreamento e devemos botar o tempo que saiu da area
    for k=1:nareas
        for j=1:nanimais
            %se estava dentro e acabou o rastreamento
            if dentroarea(j,k)
                dentroarea(j,k) = 0;
                tempoareas{j,k}.tf(contareas(j,k)) = t(cont-1);
            end
        end
    end

    %fecha o ultimo comportamento
    comportamento.tf(contcomportamento) = t(cont-1);
    comportamento.xf(:,contcomportamento) = px(:,cont-1)/pixelcm.x;
    comportamento.yf(:,contcomportamento) =(l-py(:,cont-1))/pixelcm.y;

    if criavideores
        close(aviobj);
    end

    if criavideodiff
        close(aviobj2);
    end

    if (~mostraresnatela) || exist('handles','var')
        set(0,'CurrentFigure',figvid); %seta com atual sem mostrar
    else
        figure(figvid);  %mostra na tela
    end

    hold off
    imshow(backg)
    hold on
    if ~exist('handles','var')
        set(figvid,'Visible', 'on')
    end

    %desenha as areas e salva
    desenha_areas(areas,'','b',1);

    saveas(figvid,[fotos,'/',handles.filenameSemExtensao,'areas.jpg']);

    if (~mostraresnatela) || exist('handles','var')
        set(0,'CurrentFigure',figvid); %seta com atual sem mostrar
    else
        figure(figvid);  %mostra na tela
    end

    %salva as trajetorias todas juntas
    hold off
    imshow(backg)
    hold on
    if ~exist('handles','var')
        set(figvid,'Visible', 'on')
    end

    for j=1:nanimais
        plot(px(j,:),py(j,:),'Color',vcores(mod(j,7)+1,:));
    end

    saveas(figvid,[fotos,'/',handles.filenameSemExtensao,'result.jpg']);

    %salva as trajetorias de cada animal
    if nanimais>1
        for j=1:nanimais
            hold off
            imshow(backg)
            hold on
            if ~exist('handles','var')
                set(figvid,'Visible', 'on')
            end
            plot(px(j,:),py(j,:),'Color',vcores(mod(j,7)+1,:));
            saveas(figvid,[fotos,'/',handles.filenameSemExtensao,'result',num2str(j),'.jpg']);
        end
    end

    if (~mostraresnatela) || exist('handles','var')
        close(figvid);
    end

    %if criavideodiff
    %    close(figvideodiff);
    %end

    if exist('handles','var')
        axes(handles.axes4);
        hold off
        imhandle = imshow(backg);
        set(imhandle,'ButtonDownFcn',handles.pontButtonDown);
        hold on
        for j=1:nanimais
            plot(px(j,:),py(j,:),'Color',vcores(mod(j,7)+1,:));
        end
    end


    %transforma a posicao dos animais de pixel pra cm
    pxcm = px/pixelcm.x;
    pycm = (l-py)/pixelcm.y; %inverte o eixo y

    difft = diff(t);
    for i=1:nanimais
        %calcula o vetor velocidade
        %velocidade{i}.x = diff(pxcm(i,:))*fps/procframe;
        velocidade{i}.x = diff(pxcm(i,:)) ./ difft;
        %velocidade{i}.y = diff(pycm(i,:))*fps/procframe;
        velocidade{i}.y = diff(pycm(i,:)) ./ difft;
        velocidade{i}.total = sqrt(velocidade{i}.x.^2+velocidade{i}.y.^2);
        %calcula a distancia percorrida por cada animal
        %distperc(i) = sum(velocidade{i}.total*procframe/fps);
        distperc(i) = sum(velocidade{i}.total .* difft);
    end

    if exist('handles','var')
        set(handles.trest,'String',num2str(0));
        handles.waibar.setvalue(1);
    end

    %variaveis de retorno
    for i=1:nanimais
        posicao{i}.x = pxcm(i,:);
        posicao{i}.y = pycm(i,:);
    end

end


%calcula os termos da seria da filtragem considerando deslocamentos iguais
%entre espaços de tempo iguais
function y = calctermoserie(n,i)
    if i == 1
        y = sum(1:n);
    else
        if i>n
            y = 0;
        else
            y = calctermoserie(n-1,i) + calctermoserie(n-1,i-1);
        end
    end
end

function im = desenharect(im, rect, cor,esp)

    if nargin == 3
        esp = 0;
    end

    [l,c,nc] = size(im);

    xi = max(rect(1),1);
    yi = max(rect(2),1);
    xf = min(xi + rect(3),l);
    yf = min(yi + rect(4),c);

    im(xi:xi+esp,yi:yf,1) = cor(1);
    im(xi:xf,yf-esp:yf,1) = cor(1);
    im(xf-esp:xf,yi:yf,1) = cor(1);
    im(xi:xf,yi:yi+esp,1) = cor(1);
    if nc>1
        im(xi:xi+esp,yi:yf,2) = cor(2);
        im(xi:xf,yf-esp:yf,2) = cor(2);
        im(xf-esp:xf,yi:yf,2) = cor(2);
        im(xi:xf,yi:yi+esp,2) = cor(2);
        im(xi:xi+esp,yi:yf,3) = cor(3);
        im(xi:xf,yf-esp:yf,3) = cor(3);
        im(xf-esp:xf,yi:yf,3) = cor(3);
        im(xi:xf,yi:yi+esp,3) = cor(3);
    end
end


function clickfigura(hObject, eventdata, handles)

    handles = guidata(hObject);

    axesHandle  = get(hObject,'Parent');
    pos=get(axesHandle,'CurrentPoint');
    pos = pos(1,1:2);

    global pausar

    if pausar == 0 %nao esta pausado, portanto eh dica
        %garante que o ponto esta dentro da imagem
        global dicax
        global dicay
        dicax = min(pos(1),handles.c);
        dicay= min(pos(2),handles.l);
        %else %esta pausado, portanto eh pra ajeitar posicoes antigas
        %    display('ajeitar posicao antiga')
    end
end


function mascara = calculamascara(areaproc,areaexc,fundo)

    %disp('Calculando mascara...')
    %tic

    [nl,nc,cor] = size(fundo);
    mascara = zeros(nl,nc,cor);

    %setar dentro da area de interesse
    xi = min(areaproc.x);
    xf = max(areaproc.x);
    yi = min(areaproc.y);
    yf = max(areaproc.y);
    vx = ones(1,yf-yi+1);
    for i=xi:xf
        r = inpolygon(i*vx,yi:yf,areaproc.x,areaproc.y);
        mascara(yi:yf,i,:) = r;
    end

    %zerar dentro das áreas de exclusao

    for k=1:length(areaexc)
        xi = min(areaexc(k).x);
        xf = max(areaexc(k).x);
        yi = min(areaexc(k).y);
        yf = max(areaexc(k).y);
        vx = ones(1,yf-yi+1);
        
        for i=xi:xf
            r = inpolygon(i*vx,yi:yf,areaexc(k).x,areaexc(k).y);
            mascara(yi:yf,i,:) = ~r;
        end
        
    end
    %toc
    %figure
    %imshow(mascara)
    %disp('Iniciando rastreamento...')
end




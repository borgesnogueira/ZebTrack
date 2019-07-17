%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Autor: Marcelo Borges Nogueira
%Data: 05/07/2011
%Descricao: extracts the center (cc,cr) and radius of the largest blobs
%recebe a imagem de fundo Imback, a imagem atual Imwork, o numero de blobs
%que desejamos detectar, o numero minimo de pixeis em um blob e a
%toloerancia tol para determinar se um pixel eh pixel de blob ou nao

%Inputs:
% Imwork -> Frame atual
% Imback -> wbackg que é o background;
% V ->
% n -> Número de animais a serem detectados (namimais);
% mascara -> A mascara (região de interesse selecionada pelo usuário [é um array]);
% minpix, maxpix -> define o TAMANHO MINIMO e MAXIMO, em pixeis, de uma área para ser considerada de um animal.
% tol -> tolerância/threshold;
% avi -> aviobj2 que é o objeto de video diferença (não um vídeo!);
% criavideo -> flag pra criar o video-diferença (criavideodiff);
% tipsfundo -> flag que diz se há dicas na detecção no fundo;


%outputs:
% cc, cr ->
% radius ->
% boudingbox -> vetor que vem de stats(i).BoundingBox com as coordenadas [x0 y0 w(width) h(height)] onde x0 e y0 são as coordenadas do canto inferior esquerdo
% das bounding boxes dos blobs ([h w] seriam as dimensões da bounding box enquanto matriz!);
% ndetect ->
% avi ->
% foremm -> foreground com a mascara aplicada (fore & mascara) e pós operações morfológicas para eliminar blobs pequenos;



function [cc,cr,radius,boundingbox,ndetect,avi,foremm, fore] = extractnblobs(Imwork,Imback,V,n,mascara,minpix,maxpix,tol,avi,criavideo,tipsubfundo)

cc=0;
cr=0;
radius=0;
ndetect = 0;
boundingbox = 0;

[MR,MC,cor] = size(Imback);     %R == rolls, C == columns. aqui pega-se as dimensões do background.

if maxpix == 0
    maxpix = MR*MC/2;       % 50% da imagem
end

fore = zeros(MR,MC);

colorida = (cor == 3);      %se for colorida retorna 1;


if tipsubfundo == 0
    
    % subtracao de fundo basica: valor da diferença maior que threshold
    if ~colorida
        fore = abs(Imback - Imwork) > tol;
    else
        fore = (abs(Imwork(:,:,1) - Imback(:,:,1)) > tol) | (abs(Imwork(:,:,2) - Imback(:,:,2)) > tol) | (abs(Imwork(:,:,3) - Imback(:,:,3)) > tol);
    end
    
else
    
    % subtracao de fundo gaussiana: valor da diferença maior que
    % threshhold*raiz(variancia) para cada pixel
    if ~colorida
        fore = abs(Imback - Imwork) > tol*V(:,:,4);
    else
        fore = (abs(Imwork(:,:,1)-Imback(:,:,1)) > tol*V(:,:,1)) ...
            | (abs(Imwork(:,:,2) - Imback(:,:,2)) > tol*V(:,:,2)) ...
            | (abs(Imwork(:,:,3) - Imback(:,:,3)) > tol*V(:,:,3));
    end
    
end


%fzer um AND com a mascara
fore = fore & mascara;

% Morphology Operation  erode to remove small noise
%foremm = bwmorph(fore,'erode',2);
%foremm = bwmorph(foremm,'dilate',5);

%foremm = bwmorph(fore,'open',2);

%change the size of the elements of morphological operations based on image
%size. The base will be 720x480 images

ImArea = MR*MC;
mult = sqrt(ImArea/(720*480)); %since we specify radius below, root the multiplier
radImopen = max(1,round(mult*1));
radBwmorph = max(2,round(mult*3));

foremm = imopen(fore,strel('disk',radImopen));%erosion followed by a dilation
foremm = bwmorph(foremm,'dilate',radBwmorph);%dilate even more to join adjacent blobs

%remover operacoes morfologicas
%foremm = fore;

if criavideo
    %figure(h);
    junto = 255*foremm;
    imhandle = imshow(junto);
    set(imhandle,'ButtonDownFcn',@clickfigura );
    writeVideo(avi,uint8(junto));
end

% separete the objects found
labeled = bwlabel(foremm,8); %conectividade 8

stats = regionprops(labeled,['basic']);%basic mohem nist (only relevant information here: Area, centroid coordinates and Bounding box coordinates);
[N,W] = size(stats);                   %N-> número de blobs;
if N < 1 %|| n>N %se nao achou nenhum ou achou menos que o pedido a função acaba;
    return
end

% do bubble sort (large to small) on regions in case there are more than 1
id = zeros(N);
for i = 1 : N
    id(i) = i;
end
for i = 1 : N-1
    for j = i+1 : N
        if stats(i).Area < stats(j).Area
            tmp = stats(i);
            stats(i) = stats(j);
            stats(j) = tmp;
            tmp = id(i);
            id(i) = id(j);
            id(j) = tmp;
        end
    end
end


% conta quantos blobs tem mais que minpix e menos que maxpix
%falta remover os maiores que maxpix
cont=0;
for i=1:N
    if stats(i).Area > minpix && stats(i).Area < maxpix
        cont=cont+1;
    else
        break;
    end
end
selected = (labeled==id(1));


%ndetect = min(n,cont); %get the ceter of mass of at most n blobs
ndetect = cont;
for i=1:ndetect
    centroid = stats(i).Centroid;
    radius(i) = sqrt(stats(i).Area/pi);
    cc(i) = centroid(1);
    cr(i) = centroid(2);
    boundingbox(i,1:4) = stats(i).BoundingBox;
end

return
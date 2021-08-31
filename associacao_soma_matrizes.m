function [pxn,pyn,detectado,caixa] = associacao_soma_matrizes(nanimais, ndetect, bc2_avg_vector,centroids, cx, cy, px_ant, py_ant, l, c, detectado,caixa,boundingbox)
%{
note que existem nanimais. Isso que define a quantidade de centroides 
(existem, por definiÃ§Ã£o, a mesma quantidade de centrÃ³ides que de animais).
Ao mesmo tempo, a quantidade de blobs Ã© uma caracterÃ­stica do frame em
questÃ£o.
Logo, Ã© possÃ­vel definir duas matrizes de distancia, ambas de formato qtd_blobs x
nanimais (qtd_centroids), tanto no espaÃ§o de cores quanto no espaÃ§o da imagem.
Como definir essas matrizes?
Vale saber que [cx cy] sÃ£o os centrÃ³ides dos blobs.

o primeiro passo Ã© captar os pontos passados:

>> px_antes = px(:,cont-1); py_antes = py(:,cont-1);

e colocÃ¡-los numa matriz:

>> mat_pxs = [px_antes py_antes];

agora define-se as matrizes:

>> D_cores = pdist2(mat_bc2_avg_v, centroids); 
>> D_imagem = pdist2(centro_de_blobs, mat_pxs);

daÃ­ basta somar:

>> D = D_cores + D_imagem
--------------
%}

%    save('checando_soma_matrizes','bc2_avg_vector','centroids','cx', 'cy', 'px_ant', 'py_ant', 'l', 'c', 'detectado')
    pxn = px_ant;
    pyn = py_ant;
    
    %se nenhum blob for achado minha função termina
    
    if ndetect==0
        return
    end
    
    %percorrer a matriz bc2_avg_vector e substituir as células vazias por
    %-1
    
    for i=1:ndetect
        if isempty(bc2_avg_vector{i,1})
            bc2_avg_vector{i,1} = [-1 -1 -1];
        end
    end
    mat_bc2_avg_v = cell2mat(bc2_avg_vector);
   
  % if (mat_bc2_avg_v == [])
  %   mat_bc2_avg_v = [0 0 0];
  %  end
  %  mat_bc2_avg_v = [1 1 1];
    diagonal_tela = sqrt(l^2 + c^2);
    diagonal_cores = 255*sqrt(3); % estou me valendo de abuso de linguagem ao chamar "diagonal cores"
                                  % note que a maior distância que pode
                                  % ocorrer dentro de um cubo [0 255]x[0
                                  % 255] é aquela da maior diagonal
                                  % interna (um ponto em [0 0 0] e outro em [255 255 255])
                                  % cujo tamanho é 255*sqrt(3)


    centroides_boundingbox = [cx' cy'];
    pontos_anteriores_imagem = [px_ant py_ant];
    D_imagem = pdist2(centroides_boundingbox, pontos_anteriores_imagem)/diagonal_tela;
    D_cores = pdist2(mat_bc2_avg_v, centroids)/diagonal_cores;
   
    [lin, cols] = size(bc2_avg_vector);
    for i=1:1:ndetect
        if bc2_avg_vector{i,1} == -1
           D_cores(i,:) = D_imagem(i,:);
        end
    end
    
    %media das distancias euclidiana e de cores em cada frame
%    iter = 0;
%    xImagem = 0;
%    yImagem = 0;
%    xCores = 0;
%    yCores = 0;
%    
%   [a,b] = size(D_imagem);
%   for i=1:1:a
%       xImagem = D_imagem(i,1) + xImagem;
%       yImagem = D_imagem(i,2) + yImagem;
%       xCores = D_cores(i,1) + xCores;
%       yCores = D_cores(i,2) + yCores;
%       iter = iter+1;
%   end
%   
%   xImagem = xImagem/iter;
%   yImagem = yImagem/iter;
%   xCores = xCores/iter;
%   yCores = yCores/iter;
    
    alfa = 1;
    D = (alfa*D_cores) + ((1-alfa)*D_imagem);

    blobdetectado = zeros(1,ndetect);
    
    %enquanto tiver animais nao associados ou blobs nao associados
    while ~isempty(find(detectado==0, 1)) && ~isempty(find(blobdetectado==0, 1))
        %acha o minimo atual
        [blob,animal]=find(D==min(min(D)));
        [value,ind] = min(D(:));
        [blob,animal] = ind2sub(size(D),ind);
       
        if ~detectado(animal) && ~blobdetectado(blob) %associa o animal ao blob se eles estiverem livres
            D(blob,:) = ones(1,nanimais)*2; %bota um valor alto para nao ser mais o minimo na linha e coluna inteira, ja que esse blob e animal serão associados
            D(:,animal) = ones(ndetect,1)*2;
            detectado(animal) = 1;
            blobdetectado(blob) = 1;
            pxn(animal) = cx(blob);           %Associando o centro de massa do blob com a posição do animal
            pyn(animal) = cy(blob);
            caixa(animal,1:4) = boundingbox(blob,:);
        else
            break
        
    end
end

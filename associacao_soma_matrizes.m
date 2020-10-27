function [pxn,pyn] = associacao_soma_matrizes(bc2_avg_vector,centroids, cx, cy, px_ant, py_ant, l, c)
%{
note que existem nanimais. Isso que define a quantidade de centroides 
(existem, por definição, a mesma quantidade de centróides que de animais).
Ao mesmo tempo, a quantidade de blobs é uma característica do frame em
questão.
Logo, é possível definir duas matrizes de distancia, ambas de formato qtd_blobs x
nanimais (qtd_centroids), tanto no espaço de cores quanto no espaço da imagem.
Como definir essas matrizes?
Vale saber que [cx cy] são os centróides dos blobs.

o primeiro passo é captar os pontos passados:

>> px_antes = px(:,cont-1); py_antes = py(:,cont-1);

e colocá-los numa matriz:

>> mat_pxs = [px_antes py_antes];

agora define-se as matrizes:

>> D_cores = pdist2(mat_bc2_avg_v, centroids); 
>> D_imagem = pdist2(centro_de_blobs, mat_pxs);

daí basta somar:

>> D = D_cores + D_imagem
--------------
%}

    mat_bc2_avg_v = cell2mat(bc2_avg_vector);
    D_cores = pdist2(mat_bc2_avg_v, centroids);
    
    centroides_boundingbox = [cx' cy'];
    pontos_anteriores_imagem = [px_ant py_ant];
    D_imagem = pdist2(centroides_boundingbox, pontos_anteriores_imagem);
   % disp(D_cores);
    D = D_cores + D_imagem;
   % disp(D);
    %disp(centroides_boundingbox);
    %disp(pontos_anteriores_imagem);
    [~,I] = min(D,[],1);
    centroides_escolhidos = centroides_boundingbox(I,:);
    pxn = centroides_escolhidos(:,1);
    pyn = centroides_escolhidos(:,2);
    %disp(centroides_boundingbox(I,:));
    disp('estou dentro da associacao_soma_matrizes');
    disp(['positions = ' num2str(I)]);
    disp('D = ');
    disp(D);
    disp('centroides_boundigbox = ');
    disp(centroides_boundingbox);
end

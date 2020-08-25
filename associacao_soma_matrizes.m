function [pxn,pyn] = associacao_soma_matrizes(bc2_avg_vector,centroids, cx, cy, px_ant, py_ant)
%{
note que existem nanimais. Isso que define a quantidade de centroides 
(existem, por definição, a mesma quantidade de centróides que de animais).
Ao mesmo tempo, a quantidade de blobs é uma característica do frame em
questão.
Logo, é possível definir duas matrizes, ambas de formato qtd_blobs x
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
    pontos_imagem = [px_ant py_ant];
    D_imagem = pdist2(centroides_boundingbox, pontos_imagem);
    pxn = 3
    pyn = 2
    disp(D_cores);
    disp(D_imagem);
end
function [pxn,pyn] = associacao_soma_matrizes()
%{
note que existem nanimais. Isso que define a quantidade de centroides 
(existem, por definição, a mesma quantidade de centróides que de animais).
Ao mesmo tempo, a quantidade de blobs é uma característica do frame em
questão.
Logo, é possível definir duas matrizes, ambas de formato qtd_blobs x
nanimais (qtd_centroids), tanto no espaço de cores quanto no espaço da imagem.
Como definir essas matrizes?

o primeiro passo é o seguinte:

>> centro_de_blobs = boundingbox(:,1:2) +0.5*boundingbox(:,3:4)

isso fará com que tenhamos os centros dos blobs (dos quadrados)
o segundo passo é captar os pontos passados:

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
end
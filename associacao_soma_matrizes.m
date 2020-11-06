function [pxn,pyn] = associacao_soma_matrizes(bc2_avg_vector,centroids, cx, cy, px_ant, py_ant, l, c, detectado)
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

%    save('checando_soma_matrizes','bc2_avg_vector','centroids','cx', 'cy', 'px_ant', 'py_ant', 'l', 'c', 'detectado')

    mat_bc2_avg_v = cell2mat(bc2_avg_vector);
    
    diagonal_tela = sqrt(l^2 + c^2);
    diagonal_cores = 255*sqrt(3); % estou me valendo de abuso de linguagem ao chamar "diagonal cores"
                                  % note que a maior dist�ncia que pode
                                  % ocorrer dentro de um cubo [0 255]x[0
                                  % 255] � aquela da maior diagonal
                                  % interna (um ponto em [0 0 0] e outro em [255 255 255])
                                  % cujo tamanho � 255*sqrt(3)

    disp('mat_bc2_avg_v = ');
    mat_bc2_avg_v
    
    D_cores = pdist2(mat_bc2_avg_v, centroids)/diagonal_cores;

    [lin, cols] = size(bc2_avg_vector)
    for i=1:1:lin
        disp('entrei aqui')
        if isempty(bc2_avg_vector{i,:})
           %bc2_avg_vector{i,1} = [0.5 0.5 0.5];
            disp('vazioooo')
            disp(['lin = ', int2str(lin)])
            D_cores(lin,:) = 0.5*ones(1,cols)
        end
    end
    
    disp('size D_cores')
    disp(size(D_cores))

    %disp('mat_bc2_avg_v=') %remover depois
    %mat_bc2_avg_v %remover depois
    centroides_boundingbox = [cx' cy'];
    pontos_anteriores_imagem = [px_ant py_ant];
    D_imagem = pdist2(centroides_boundingbox, pontos_anteriores_imagem)/diagonal_tela;
%    disp('dcores='); %remover depois
%    disp(D_cores); %remover depois
    %disp(D_imagem);
    disp('size D_imagem')
    disp(size(D_imagem))
    D = D_cores + D_imagem;
   % disp(D);
    %disp(centroides_boundingbox);
    %disp(pontos_anteriores_imagem);
    [~,I] = min(D,[],1);
    disp('D='); %remover depois
    D %remover depois
    disp('I='); %remover depois
    I %remover depois
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

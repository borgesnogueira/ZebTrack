%essa função atua em apenas um ÚNICO FRAME, assim, é usada toda vez que se
%deseja associar os blobs de um frame com os animais detectados.

%IDEIA:
% Antes de tudo, mudar as posições atuais (px_anterior,py_anterior) para as da dica (caso houver), i.e. :
%     px_anterior <- dicax
%     py_anterior <- dicay
% depois, trabalhar em cima dos casos em que temos mais blobs que animais ou menos blobs que animais. O que importa, é que no final, associamos, em ambos os caso,
% as posições dos animais com a dos blobs (a relação é sempre animal(i)<-blob(j) ):
%     PRIMEIRO CASO(peixe mais próximo com o j-ésimo blob)
%       (i) px_novo(maisproximo) = cx(j);
%       (ii)py_novo(maisproximo) = cy(j);
%     SEGUNDO CASO(k-ésimo peixe com o blob mais próximo)
%       (i)px_novo(k) = cx(maisproximo);           
%       (ii)py_novo(k) = cy(maisproximo);
%       
% Finalmente, para animais não detectados, matemos a sua posição atual!

%LEGENDA:
%-> alpha = coeficiente da ponderação nos cálculos das distâncias
%-> caixa = recebe uma bounding box de um dado blob quando realizada a associação adequada (do k-esimo peixe e com 4 coordenadas, ou seja, k x 4)
%-> cx/cy = posições atuais do CENTRO DE MASSA do blob
%-> px_anterior/py_anterior = posições atuais do peixe(anteriores)
%-> cor_atual_blobs = vetor que armazena os valores escalares das cores atuais dos peixes
%-> vetor_media_peixes = vetor que armazena os valores das cores médias de cada peixe
%-> vetor_variancia_peixes = vetor que armazena os valores das variâncias das cores de cada peixe
%       OBS: o tamanho dos três vetores acima É IGUAL.

function [px_novo, py_novo, detectado, caixa] = associatefudera(nanimais, num_blobs_detected, px_anterior, py_anterior, cx, cy, radius, ...
                                                        boundingbox, detectado, dicax, dicay, caixa, l, c, frame, ...
                                                        cor_atual_blobs, vetor_media_peixes, vetor_variancia_peixes, ...
                                                        alpha)
                                                    
                        %No uso da função associate px_novo/px_anterior representam as variáveis px e py, que
    px_novo = px_anterior;          %guardam as posições em x e y dos frames ao longo dos quadros Novo e
    py_novo = py_anterior;          %Anterior.

    %se nenhum blob for achado minha função termina
    if num_blobs_detected == 0
        return
    end

    %verifica a dica (caso em que a pessoa que está fazendo o rastreio julgar necessário assinalar o local em que o peixe está)
    if dicax ~=-1 && dicay ~=-1

        %acha o animal mais proximo da dica
        mindist = l^2 + c^2;        %é irrelevante começar com o quadrado do tamanho da diagonal da tela de ratreio aqui (que é o caso).

        for k=1:nanimais
            dist = sqrt( (px_anterior(k) - dicax)^2 + (py_anterior(k) - dicay)^2 );     %distância euclidiana entre os pontos e as dicas.

            if dist < mindist           %atualizar a mindist para a distancia entre os pontos e as dicas
                mindist = dist;
                maisproximod = k;       %pego o indice do animal mais proximo(?)
            end

        end

        %as posições dos animais de índice k recebem as posições das dicas
        %pode ser que inclusivem fossem suas posições originais.
        px_anterior(maisproximod) = dicax;
        py_anterior(maisproximod) = dicay;

    end
    
    %tratamento quando entra uma cor atual que é um NaN
    alpha_tratado = alpha;  %alpha_tratado vai mudar se cor_atual_blobs(i) for um NaN! (a gente passa a trabalhar só com distâncias euclidianas)
  
    
    %INICIO PROPRIAMENTE DITO DA FUNÇÃO

    
    %se foram achados menos blobs que animais ( [-]blobs e [+] animais )
    if num_blobs_detected < nanimais
                                        %para cada blob, acha o animal mais proximo e associa o seu centro
                                        %de massa a posicao atual deste animal
        for j=1:num_blobs_detected %percorre os blobs

            maisproximo = -1;       %Flag para o caso de não houverem animais mais próximos
            primeiravez = true;
            
            %o blob vai ter sua distância comparada com a de TODOS os animais.
            for k=1:nanimais
     
                %tratamento de alpha
                if isnan(cor_atual_blobs(k))
                    alpha_tratado = 1;
                    dist_cor = 0;   %não faz sentido usar a distância no espaço de cores nessas condições;
                else
                    alpha_tratado = alpha;
                    dist_cor = calcula_Mahalanobis(cor_atual_blobs(j), vetor_media_peixes(k), vetor_variancia_peixes(k)); %calcula a distância em um espaço de cores
                end
                
                %cx/cy correspondente ao 'c'entro de massa do blob,
                %já px_anterior/py_anterior a posição anterior do animal k!
                dist_euclidiana = sqrt( (px_anterior(k) - cx(j))^2 + (py_anterior(k) - cy(j))^2 );     %calcula a distância euclidiana.
                
                dist = alpha_tratado*dist_euclidiana + (1 - alpha_tratado)*dist_cor;    %distância ponderada
                
                if primeiravez && detectado(k) == 0
                   primeiravez = false;
                   mindist = dist;
                end
                
                if (dist <= mindist) && (detectado(k) == 0)      %pra que a distância do blob seja associada com o do k-ésimo animal, antes, precisa-se ter um k-ésimo animal detectado
                    mindist = dist;
                    maisproximo = k;
                end

            end

            if maisproximo ~= -1                    %só descubro depois de verificar pra todos os peixes no for anterior
                px_novo(maisproximo) = cx(j);           %Associando o centro de massa do blob com a posição do animal
                py_novo(maisproximo) = cy(j);

                detectado(maisproximo) = 1;         %Aqui digo que foi detectado um blob correspondente ao k-ésimo animal(?)
                caixa(maisproximo,1:4) = boundingbox(j,:);  %a caixa do peixe vem da bounding box do blob
            end

        end

    %foram achados mais blobs que nanimais ( [+]blobs e [-]animais )
    else

        blobassociado = zeros(num_blobs_detected);     %vetor que ira decorar cada blob que foi associado a um animal

        %para cada animal, associa o blob mais proximo
        for k=1:nanimais
            maisproximo = -1;
            primeiravez = true;
            
            %tratamento de alpha
            if isnan(cor_atual_blobs(k))
                alpha_tratado = 1;
                dist_cor = 0;   %não faz sentido usar a distância no espaço de cores nessas condições;
            else
                alpha_tratado = alpha;
                dist_cor = calcula_Mahalanobis(cor_atual_blobs(k), vetor_media_peixes(k), vetor_variancia_peixes(k)); %calcula a distância em um espaço de cores
            end
            
            for j=1:num_blobs_detected
                dist_euclidiana = sqrt( (px_anterior(k) - cx(j))^2 + (py_anterior(k) - cy(j))^2 );     %calcula a distância euclidiana entre o centro de massa 
                                                                                                       %do blob e a posição atual do peixe.
                
                dist = alpha_tratado*dist_euclidiana + (1 - alpha_tratado)*dist_cor;    %distância ponderada
                
                if primeiravez && detectado(j) == 0
                    primeiravez = false;
                    mindist = dist;
                end
                
                if (dist <= mindist) && (blobassociado(j)==0)                %blobassociado(j)==0 é para saber se já encontramos o devido peixe correspondente ao blob j
                    mindist = dist;
                    maisproximo = j;
                end

            end

            if maisproximo ~= -1    %só não haverão blobs mais próximos de animais caso não seja detectado nenhum blob naquele frame!
                px_novo(k) = cx(maisproximo);
                py_novo(k) = cy(maisproximo);

                blobassociado(maisproximo) = 1;
                detectado(k) = 1;
                caixa(k,1:4) = boundingbox(maisproximo,:);
            end

        end

    end                                                 
                                                                                                 
                                                    
end

function  distanciaMahalanobis = calcula_Mahalanobis(valor_cor_atual, media, variancia)
    distanciaMahalanobis = abs((valor_cor_atual - media))/variancia;
end

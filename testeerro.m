%Lendo as matrizes antes e depois dos ajustes manuais das posições
    antes = load('result-antes-ajuste.mat');
    depois = load('result-depois-ajuste.mat');
    antes = antes.e;
    depois = depois.e;
    sucesso = 0;
    insucesso = 0;
   
    erros = {};
    erros.peixe = {};
  
    %n = size(antes.t);
    n = 58;
    %npeixes = size(antes.posicao);
    npeixes = 2;
   
    for i=1:n
        for j=1:npeixes
            posicaopeixe = rem(j,2)+1;
            erros.peixe{j}(i) = sqrt( (antes.posicao{posicaopeixe}.x(i) - depois.posicao{j}.x(i) )^2 + ( antes.posicao{posicaopeixe}.y(i) - depois.posicao{j}.y(i) )^2 );
            erros2.peixe{j}(i) = sqrt( (antes.posicao{j}.x(i) - depois.posicao{j}.x(i) )^2 + ( antes.posicao{j}.y(i) - depois.posicao{j}.y(i) )^2 );
        end
    end
    save('resulterros.mat','erros');
    
    %if a == 1 & b == 0
    %   sucesso++;
    %elseif a == 0 & b == 1 
    %   insucesso++;
    %end
            
    a = plot(min(erros.peixe{1,2},erros.peixe{1,1})<50,'r');
    hold on
   
    b = plot(min(erros2.peixe{1,2},erros2.peixe{1,1})<50);
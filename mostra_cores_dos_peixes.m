%apresenta ao usuário figures que representam as cores respectivas a cada
%peixe do experimento

function [] = mostra_cores_dos_peixes(media, variancia)
    dimX = 200;
    dimY = 100;

    S = ones(dimX, dimY); %saturation
    V = S.*0.5; %value
    
    %alocando a imagem para deixar mais rapido
    imagemHSV = zeros(dimX, dimY, 3);
    imagemHSV(:,:,2) = S;
    imagemHSV(:,:,3) = V;
    
    for i=1:1:length(media) %numero de animais da primeira media (por que media é um vetor)
        x = linspace(media(i) - 3*sqrt(variancia(i)), media(i) + 3*sqrt(variancia(i)), dimY); %a linha das cores usando a media e a variancia
        
        x(find(x<0)) = x(find(x<0)) + 1
        
        x(find(x>1)) = x(find(x>1)) - 1
        
        for j=1:dimX
            imagemHSV(j,:,1) = x;
        end
        
        %mostrando a imagem em hsv:
        figure, imshow(hsv2rgb(imagemHSV));
    end
   
    
end


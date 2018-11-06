%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Autor: Marcelo Borges Nogueira
%Data: 18/03/2015
%Descricao: Cria o fundo de uma sequencia de imagens fazendo a media destas
%utilizando os quadros de procframe em procframe. Calcula tambem a
%variancia de cada pixel, retornando na matriz V
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [fundo,V] = criafundo(caminho,filename,video,quadroini,quadrofim,procframe,waitbar)

    %disp(['Utilizando ', int2str(floor((quadrofim-quadroini)/procframe)+1), ' imagens para compor o fundo']) 
    
    %fundo = double(imread([fotos,'/frame',int2str(quadroini), '.jpeg']));
    %ja le a primeira vez!
    quadroini = floor(quadroini);
    fundo = double(read(video,quadroini));
    fundopb = double(rgb2gray(uint8(fundo)));
    [MR,MC,cor] = size(fundo);
    if cor==1
        fundo = cat(3, fundo, fundo, fundo);
    end
    cont = 1;
    M2 = fundo.^2;
    Mpb = double(rgb2gray(uint8(fundo))).^2;
     for i=quadroini+procframe:procframe:quadrofim
        cont = cont +1;
        im = double(read(video,floor(i)));
        if cor==1
            im = cat(3, im, im, im);
        end
        fundo = fundo + im;
        fundopb = fundopb + double(rgb2gray(uint8(im)));
        M2 = M2 + im.^2;
        %para preto e branco
        Mpb = Mpb + double(rgb2gray(uint8(im))).^2;
        waitbar.setvalue((i-quadroini)/(quadrofim-quadroini));
        drawnow
     end
     %calcula a media
     fundo = fundo/cont;
     fundopb = fundopb/cont;
%      for i=quadroini:procframe:quadrofim
%         im = double(imread([fotos,'/frame',int2str(i), '.jpeg']));
%         M2 = M2 + (im - fundo).^2;
%      end
      
    %calcula a variancia colorida
    %segundo pagina 277 do learing opencv, V = Sx^2/n - (Sx/n)^2
     V = M2/cont - fundo.^2;
     %calcula a variancia tons de cinza
     V(:,:,4) = Mpb/cont - fundopb.^2;

     %figure();
     %imagesc(sqrt(V(:,:,4)))

     warning off all
     fundo = uint8(fundo);
     %mostra na tela
     %figure(2)
     %imshow(fundo);
     if cor==1
        fundo = rgb2gray(fundo);
     end
     %salva o fundo
     imwrite(fundo,[caminho,'/',filename,'.jpeg'],'jpeg','Quality',100);
     save([caminho,'/',filename,'V'],'V');
     warning on all
     %disp('Novo fundo calculado')
end
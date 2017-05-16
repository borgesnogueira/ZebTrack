%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Autor: Marcelo Borges Nogueira
%Data: 05/07/2011
%Descricao: extracts the center (cc,cr) and radius of the largest blobs
%recebe a imagem de fundo Imback, a imagem atual Imwork, o numero de blobs
%que desejamos detectar, o numero minimo de pixeis em um blob e a
%toloerancia tol para determinar se um pixel eh pixel de blob ou nao

function [cc,cr,radius,boundingbox,ndetect,avi,foremm]=extractnblobs(Imwork,Imback,V,n,mascara,minpix,maxpix,tol,avi,criavideo,tipsubfundo)
  
  cc=0;
  cr=0;
  radius=0;
  ndetect = 0;
  boundingbox = 0;
  [MR,MC,cor] = size(Imback);
  if maxpix == 0
      maxpix = MR*MC/2; % 50% da imagem
  end
  
  fore = zeros(MR,MC);
  
  colorida = (cor == 3);
  
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
  
  foremm = imopen(fore,strel('disk',1));
  foremm = bwmorph(foremm,'dilate',3);
    
  if criavideo
      %figure(h);
      junto = 255*foremm; 
      imhandle = imshow(junto);
      set(imhandle,'ButtonDownFcn',@clickfigura );
      writeVideo(avi,uint8(junto));
  end
  
  % separete the objects found
  labeled = bwlabel(foremm,8); %conectividade 8
  
  stats = regionprops(labeled,['basic']);%basic mohem nist
  [N,W] = size(stats);
  if N < 1 %|| n>N %se nao achrou nenhum ou achou menos que o pedido
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
  cont=0;
  for i=1:N
      if stats(i).Area > minpix && stats(i).Area < maxpix
        cont=cont+1;
       else
           break;
      end
  end
  selected = (labeled==id(1));

 
  %ndetect = min(n,cont); %get the cetro of mass of at most n blobs
  ndetect = cont;  % get center of mass and radius of all the blobs
  for i=1:ndetect
      centroid = stats(i).Centroid;
      radius(i) = sqrt(stats(i).Area/pi);
      cc(i) = centroid(1);
      cr(i) = centroid(2);
      boundingbox(i,1:4) = stats(i).BoundingBox;
  end
  return
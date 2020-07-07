

function cor_atual = blob_colours_2(frame, l, c, cx, cy... 
                                  ,radius, boundingbox, ndetect...
                                  , wframe_log, INTENSIDADE)
                              
cor_atual = zeros(1,ndetect); %vetor com quantidade de espaços correspondentes as cores de cada animal.
mediaFrameIndividual = 0; %(Em 1 peixe e muda em cada loop).                           

somaRGB = zeros(ndetect,3)

imshow(frame);
hold on;

for k=1:1:ndetect %iterar sobre cada blob
    rectangle('Position',boundingbox(k,:));
    
    for i=round(boundingbox(k,1)):1:round(boundingbox(k,1))+round(boundingbox(k,3))
       for j= round(boundingbox(k,2)):1:round(boundingbox(k,2))+round(boundingbox(k,4))
          if wframe_log(i,j) ~= 0
              pixelHSV = reshape(rgb2hsv(frame(i,j,:)),[1,3]);
              if pixelHSV(1,3)>INTENSIDADE
                  somaRGB(k,:) = somaRGB(k,:) + reshape(frame(i,j,:),[1,3]);
              end    
              %somaRGB(k,:) = somaRGB(k,:) + frame(i,j,:);
          end    
       end 
    end
%    disp(['for k = ',num2str(k),',somaRGB = ',num2str(somaRGB(1,k))])
end
somaRGB
end                             


function cor_atual = blob_colours_2(frame, l, c, cx, cy... 
                                  ,radius, boundingbox, ndetect...
                                  , wframe_log, saturation_threshold, value_threshold)
% value_threshold == INTENSIDADE                              
cor_atual = zeros(1,ndetect); %vetor com quantidade de espaços correspondentes as cores de cada animal.
mediaFrameIndividual = 0; %(Em 1 peixe e muda em cada loop).   
how_many_pixels_were_considered = 0;

somaR = cast(zeros(ndetect,1),'uint8');
somaG = cast(zeros(ndetect,1),'uint8');
somaB = cast(zeros(ndetect,1),'uint8');

valuesR = [];
valuesG = [];
valuesB = [];

imshow(frame);
hold on;

for k=1:1:ndetect %iterar sobre cada blob
    rectangle('Position',boundingbox(k,:));
    
    for i=round(boundingbox(k,1)):1:round(boundingbox(k,1))+round(boundingbox(k,3))
       for j= round(boundingbox(k,2)):1:round(boundingbox(k,2))+round(boundingbox(k,4))
          if wframe_log(i,j) ~= 0
              pixelHSV = reshape(rgb2hsv(frame(i,j,:)),[1,3]);
              pixelRGB = reshape(frame(i,j,:),[1,3]);
              if pixelHSV(1,3)>saturation_threshold
                  how_many_pixels_were_considered = how_many_pixels_were_considered+1;
                  somaR(k,1) = somaR(k,1) + pixelRGB(1);
                  somaG(k,1) = somaG(k,1) + pixelRGB(2);                  
                  somaB(k,1) = somaB(k,1) + pixelRGB(3);
                  disp('soma RGB:');
                  disp([somaR,somaG,somaB]);
                  
                  valuesR = [valuesR, pixelRGB(1)];
                  valuesG = [valuesG, pixelRGB(2)];
                  valuesB = [valuesB, pixelRGB(3)];
                  
              end    
              %somaRGB(k,:) = somaRGB(k,:) + frame(i,j,:);
          end    
       end 
    end
%    disp(['for k = ',num2str(k),',somaRGB = ',num2str(somaRGB(1,k))])
end

disp(['how many pixels? ', num2str(how_many_pixels_were_considered)])

figure(2)
plot(valuesR,'Color','r');
hold on;
plot(valuesG,'Color','g');
hold on;
plot(valuesB,'Color','b');

disp(['mean(R)=', num2str(mean(valuesR)),'; mean(G)=',num2str(mean(valuesG)),'; mean(B)=',num2str(mean(valuesB))])

end                             
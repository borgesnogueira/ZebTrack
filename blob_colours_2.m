

function avg_vector = blob_colours_2(frame, l, c, cx, cy... 
                                  ,radius, boundingbox, ndetect...
                                  , wframe_log, value_threshold)
% value_threshold == INTENSIDADE                              
avg_vector = cell(ndetect,1) %cell array com quantidade de espaços correspondentes aos vetores de cor para cada animal.

%lista_de_imagens_rgb = cell(ndetect,1);
%lista_de_imagens_hsv = cell(ndetect,1);
%lista_de_blobs = cell(ndetect,1);
%imshow(frame);
%hold on;

for k=1:1:ndetect %iterar sobre cada blob
    rectangle('Position',boundingbox(k,:));
    
    frame_retalho = imcrop(frame, boundingbox(k,:));
    imdif_retalho = imcrop(wframe_log, boundingbox(k,:));
    retalho_mascarado = bsxfun(@times,frame_retalho, cast(imdif_retalho,class(frame_retalho)));
    r_m_hsv = rgb2hsv(retalho_mascarado);
    mask_value = r_m_hsv(:,:,3)>value_threshold;
    p_image = bsxfun(@times,frame_retalho, cast(mask_value,class(frame_retalho)));
    avg_p_i = reshape(sum(sum(p_image,1),2),[1,3]);
    how_many_pixels = sum(sum(imdif_retalho.*mask_value,1),2);
    if how_many_pixels ~= 0
        avg_p_i = avg_p_i/how_many_pixels
    end
    
    avg_vector{k,1} = avg_p_i;
    %{
    lista_de_blobs{k,1} = imcrop(wframe_log,boundingbox(k,:));
    lista_de_imagens_rgb{k,1} = imcrop(frame, boundingbox(k,:));
    lista_de_imagens_hsv{k,1} = rgb2hsv(lista_de_imagens_rgb{k,1});
    logical_mask = lista_de_imagens_hsv{k,1}(:,:,3)>value_threshold;
    average_hue(1,k) = sum(sum(~logical_mask .*  lista_de_imagens_hsv{k,1}(:,:,1)),'omitnan');
    figure(k);
    imshow(lista_de_blobs{k,1});
    %}
end
%disp(average_hue);
end                             
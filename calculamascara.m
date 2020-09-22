function mascara = calculamascara(areaproc,areaexc,fundo)

    %disp('Calculando mascara...')
    %tic

    [nl,nc,cor] = size(fundo);
    mascara = zeros(nl,nc,cor);

    %setar dentro da area de interesse
    xi = min(areaproc.x);
    xf = max(areaproc.x);
    yi = min(areaproc.y);
    yf = max(areaproc.y);
    vx = ones(1,yf-yi+1);
    for i=xi:xf
        r = inpolygon(i*vx,yi:yf,areaproc.x,areaproc.y);
        mascara(yi:yf,i,:) = r;
    end

    %zerar dentro das áreas de exclusao

    for k=1:length(areaexc)
        xi = min(areaexc(k).x);
        xf = max(areaexc(k).x);
        yi = min(areaexc(k).y);
        yf = max(areaexc(k).y);
        vx = ones(1,yf-yi+1);
        
        for i=xi:xf
            r = inpolygon(i*vx,yi:yf,areaexc(k).x,areaexc(k).y);
            mascara(yi:yf,i,:) = ~r;
        end
        
    end
    %toc
    %figure
    %imshow(mascara)
    %disp('Iniciando rastreamento...')
end
function desenha_areas(areas,ptrfunc,cor,numero)
%desenha as areas pligonais presentes em areas no eixo atual

nareas = length(areas);
hold on
for k=1:nareas 
    if ~isempty(areas(k).x)
        linehandle = line(areas(k).x,areas(k).y,'Color',cor);
        set(linehandle,'ButtonDownFcn', ptrfunc);
        if numero ~= -1
            %local da impressao do número da área
            tx = mean(areas(k).x);
            ty = mean(areas(k).y);
            texthandle = text(tx+2,ty+9,num2str(k+numero-1),'FontSize',11,'Color',cor);
            set(texthandle,'ButtonDownFcn', ptrfunc);
        end
    end
end


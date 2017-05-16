classdef uiwaitbar
    properties
        ax
        hp
        v
    end
    methods
        function obj =uiwaitbar(varargin)
            a=varargin{1};
            obj.v = 0;
            if ishandle(a)
                obj.ax = a;
                set(obj.ax,'XLim',[0 1], 'YLim',[0 1], ...
                    'XTick',[], 'YTick',[], 'Box','on', 'Layer','top', ...
                    'Units','normalized');
                obj.hp = patch([0 0 obj.v obj.v], [0 1 1 0], 'r', 'Parent',obj.ax, ...
                    'FaceColor','b', 'EdgeColor','none');
            else %cria o axes com a posicao passada
                obj.ax = axes('Units','normalized',...
                    'Position',a,...
                    'XLim',[0 1], 'YLim',[0 1], ...
                    'XTick',[], 'YTick',[], 'Box','on', 'Layer','top');
                if nargin > 1
                    set(obj.ax,'Parent',varargin{2});
                end
                obj.hp = patch([0 0 obj.v obj.v], [0 1 1 0], 'r', 'Parent',obj.ax, ...
                    'FaceColor','b', 'EdgeColor','none');
            end
            uistack(obj.ax, 'top');
        end
        function setvalue(obj,valor)
            if valor > 1 && valor <= 100
                obj.v = valor/100;
            end
            if valor <= 1 && valor >= 0
                obj.v = valor;
            end
            set(obj.hp, 'XData',[0 0 obj.v obj.v])
        end
        function visivel(obj,v)
            set(obj.ax,'Visible',v);
            set(obj.hp,'Visible',v);
            uistack(obj.ax, 'top');
        end
    end
end

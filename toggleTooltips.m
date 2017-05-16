function status = toggleTooltips( parent , varargin)
% TOGGLETOOLTIPS Easy toggling on/off for all tooltips within parent object
%
% Sometimes it's convenient to show tooltips; other times you might want to
% hide them. |toggleTooltips| makes switching between these conventions
% trivially easy.
%
%   toggleTooltips(parent)
%      ...toggles OFF or ON all tooltips of all objects that are children of
%      the specified parent.
%
%   toggleTooltips(parent, onOff)
%      ...also allows you to specify onoff, using either 'on' or 'off'.
%      If onOff == 'on', tooltipstrings are turned on.
%      If onOff == 'off', tooltipstrings are turned off.
%
%   status = toggleTooltips(...)
%      ...returns the state of the tooltips AFTER the function has run.
%      Values will be either 'on' or 'off', if the command is successful,
%      or 'fail' otherwise.
%
% % EXAMPLE:
% f = figure('defaultUicontrolUnits','normalized','menubar','none');
% vPos = 0.05:0.225:0.725; dim = 0.175;
% for ii = 1:4
% uicontrol('style','pushbutton','pos',[0.05 vPos(ii) 0.9 dim],...
%    'string',num2str(ii),'tooltipstring',['Tooltip ', num2str(ii)]);
% end
%
% toggleTooltips(f)
%
% toggleTooltips(f,'on')
%
% currentStatus = toogleTooltips(f);
%
%
% Written by Brett Shoelson, PhD
% brett.shoelson@mathworks.com
% 11/27/12
%
% Copyright 2012 The MathWorks, Inc.

if nargin < 1
    error('toggleTooltips: Requires at least one input argument, specifying the parent you want to operate on.');
end
if ~ishandle(parent)
    error('toggleTooltips: ''parent'' must be a valid handle.')
end
if nargin > 1
    onOff = varargin{1};
    if ~any(strcmpi(onOff,{'on','off'}))
        error('toggleTooltips: Inappropriate specification of onOff');
    end
else
    onOff = 'toggle';
end

tooltips = getappdata(parent,'tooltips');
if isempty(tooltips)
    allChildren = findall(parent);
    tooltips = struct('handle',[],'tooltipval','');
    for ii = 1:numel(allChildren)
        tts = [];
        try
            tts = get(allChildren(ii),'tooltipstring');
        end
        if ~isempty(tts)
            tooltips(ii).handle = allChildren(ii);
            tooltips(ii).tooltipval = tts;
        end
    end
    setappdata(parent,'tooltips',tooltips);
end

if strcmp(onOff,'toggle')
    onOff = 'on';
    for ii = 1:numel(tooltips)
        if ~isempty(get(tooltips(ii).handle,'tooltipstring'))
            % Tooltips are currently on
            onOff = 'off'; %
            break
        end
    end
end
status = 'fail';

switch onOff
    case 'on'
        for ii = 1:numel(tooltips)
            set(tooltips(ii).handle,'tooltipstring',tooltips(ii).tooltipval);
        end
        status = 'on';
    case 'off'
        for ii = 1:numel(tooltips)
            set(tooltips(ii).handle,'tooltipstring','');
        end
        status = 'off';
end
if nargout < 1
    clear status
end

end


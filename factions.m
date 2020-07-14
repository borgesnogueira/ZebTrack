%sends commands (actions) to external hardware
%conditiontype:
%types of conditions to send actions:
%1 - entering area; 2 - leaving area;
%3 - inside area; 4 - ouside area
%area: area analised
%animal: animal analised
%actions: set of actions given by user
%s: serial link

function [r] = factions(conditiontype, area, animal, actions,s)
    r=0;
    for i=1:actions.nactions
        if actions.condition(i) == conditiontype && actions.area(i) == area
                fprintf(s,num2str(actions.command(i)));
                r=1;
        end
    end
end


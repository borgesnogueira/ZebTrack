function areasequence_computation(tempoareas)

% data receives tempoareas and its shape
data = tempoareas;
[lines, cells] = size(data);

% In the first step, let's build a pair of vectors
% which elements are the ti and tf elements, at the current step
ti_vector = [];
tf_vector = [];

for i = 1:cells
    ti_vector(i) = data{1,i}.ti(1);
    tf_vector(i) = data{1,i}.tf(1);
end

% while the ti_vector not full of intmax, keep the loop going
while not(isempty(ti_vector(ti_vector<intmax)))
    
    %testing loop, remove later
    disp('data: ')
    for i=1:cells
        disp(data{1,i})
    end
    % testing loop, remove later
    
    % In the first step, let's build a pair of vectors
    % which elements are the ti and tf elements, at the current step
    ti_vector = [];
    tf_vector = [];
    
    for i = 1:cells
        disp(i);
        ti_vector(i) = data{1,i}.ti(1)
        tf_vector(i) = data{1,i}.tf(1);
    end
    
    % finding the lowest value and its position
    [low_value, pos] = min(ti_vector);
    
    % Preparing the sentence to print
    title = ['Area ', num2str(pos),' :'];
    first_sentence = ['Came in at ', num2str(low_value)];
    last_sentence =  ['Left at ', num2str(tf_vector(pos))];
    
    % printing...
    disp(title);
    disp(first_sentence);
    disp(last_sentence);
    
    % is the ti_vector 1x1 or not?
    [a,b] = size(data{1,pos}.ti);
    
    %debugging only, remove later
    disp('a = ')
    disp(a)
    disp('b = ')
    disp(b)
    %debugging only, remove later
    
    if b ~= 1
        % Erasing the just-found elements
        data{1,pos}.ti = data{1,pos}.ti(2:end);
        data{1,pos}.tf = data{1,pos}.tf(2:end);
    else
        % Do not erase, just put intmax in it
        data{1,pos}.ti = intmax;
        data{1,pos}.tf = intmax;
    end
end
function areasequence_computation(tempoareas)

% data receives tempoareas and its shape
data = tempoareas;
[lines, cells] = size(data);

% In the first step, let's build a pair of vectors
% which elements are the ti and tf elements, at the current step
ti_vector = [];
tf_vector = [];


for j = 1:lines % j represents the amount of animals we have in the video
    
    animal_text = [' ==================  Animal ', num2str(j),' =================='];
    disp(animal_text)
    
    for i = 1:cells % i represents the amount of areas we have in the video
        ti_vector(i) = data{j,i}.ti(1);
        tf_vector(i) = data{j,i}.tf(1);
    end

    % while the ti_vector not full of intmax, keep the loop going
    while not(isempty(ti_vector(ti_vector<intmax)))
        if isempty(ti_vector(ti_vector<intmax))
            disp('is empty, yeah!! Im in the beginning')
        end

        % In the first step, let's build a pair of vectors
        % which elements are the ti and tf elements, at the current step
        ti_vector = [];
        tf_vector = [];

        for i = 1:cells
            ti_vector(i) = data{j,i}.ti(1);
            tf_vector(i) = data{j,i}.tf(1);
        end

        % finding the lowest value and its position
        [low_value, pos] = min(ti_vector);

        % the following condition is written in order to correct
        % the unknown, so far, behaviour of the algorithm
        % of finding an intmax as "low_value"

        if low_value ~= intmax & ~(low_value==0 & tf_vector(pos)==0) 
            % Preparing the sentence to print
            title = ['Area ', num2str(pos),' :'];
            first_sentence = ['    Came in at ', num2str(low_value)];
            last_sentence =  ['    Left at ', num2str(tf_vector(pos))];

            % printing...
            disp(title);
            disp(first_sentence);
            disp(last_sentence);
        end

        % is the ti_vector 1x1 or not?
        [a,b] = size(data{j,pos}.ti);

        if b ~= 1
            % Erasing the just-found elements
            data{j,pos}.ti = data{j,pos}.ti(2:end);
            data{j,pos}.tf = data{j,pos}.tf(2:end);
        else
            % Do not erase, just put intmax in it
            data{j,pos}.ti = intmax;
            data{j,pos}.tf = intmax;
        end

    end
    
    animal_end = ['==============================================='];
    disp(animal_end)
end    
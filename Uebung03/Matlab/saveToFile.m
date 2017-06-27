% This functions saves the temporal model to a file.
% This has to be a seperate function, because matlab...

function [] = saveToFile(filename, tempModel)
    filename = strcat('../Features/', num2str(filename), '_features.mat');
    save(filename, tempModel);
end
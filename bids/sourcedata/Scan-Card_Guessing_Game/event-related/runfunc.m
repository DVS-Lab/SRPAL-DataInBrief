% This code runs the genTrialList function to generate param files

% Specify the list numbers and it will run them for you.

list = 10300:10399

for ii = 1:length(list)
    num = list(ii)
    genTrialList(num)
end
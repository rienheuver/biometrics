function outputArg1 = idCountTotal(idCountMap,personId)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
    if personId == 1
        outputArg1 = 0;
    elseif personId == 2
        outputArg1 = idCountMap(1);
    else
        outputArg1 = idCountMap(personId-1) + idCountTotal(idCountMap, personId-1);
    end
end
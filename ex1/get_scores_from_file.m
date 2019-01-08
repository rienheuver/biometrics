
function [S, Id] = get_scores_from_file%
%
% Loads score matrix and plots info.
%%
S = load('scorematrix.txt', '-ascii');
Id = load('id.txt', '-ascii');
[np, nt] = size(S);
nId = max(Id);
Entries = (1:np);
Ratio = np / nId;
%% Creating a dictionary that links each individual to each of his scores
fprintf(' Size of score matrix: %u x %u\n',np,nt);
fprintf(' Number of identities: %u\n', nId);
fprintf(' Ratio: %u\n', Ratio);

% figure(1); plot(Entries, Id); 
% xlabel('Entry'); ylabel('Identity'); title('Mapping entry number to identity');
%  
% figure(2); imagesc(S); colormap('gray');
% ylabel('test'); xlabel('reference'); title('Score matrix');

idCountMap = containers.Map('KeyType', 'single', 'ValueType', 'single');
currentId = 1;
currentCount = 0;
for i = Id
    if i == currentId
        currentCount = currentCount + 1;
    else
        idCountMap(currentId) = currentCount;
        currentId = currentId + 1;
        currentCount = 1;
    end
end
idCountMap(currentId) = currentCount;

%%
genuineScores = zeros(1, 1780);
genuineCounter = 0;
for i=1:length(idCountMap) % 275 -> person 2
    for j=1:idCountMap(i) % 3 -> 2
        for k=1:idCountMap(i) % 3 -> 3
            if k > j
                genuineCounter = genuineCounter + 1;
                genuineScores(genuineCounter) = S(j+idCountTotal(idCountMap, i),k+idCountTotal(idCountMap, i));
            end
        end
    end
end
disp("Finished making genuine scores");
%%
disp(length(S));
for i=1:3
    disp(i)
end
j=5;
disp("Test: " + j);
imposterCount = 0;
for i=1:length(idCountMap)
    imposterCount = imposterCount + idCountMap(i) * (length(S)-(idCountTotal(idCountMap, i) + idCountMap(i)));
end
disp(imposterCount);
%%
imposterScores = zeros(1,imposterCount);
imposterCounter = 0;
% Loop over persons
for i=1:length(idCountMap) % 1 -> 275
    disp("Finished with person " + i);
    % Loop from right part of yellow block until right side of matrix
    for j=idCountTotal(idCountMap, i) + idCountMap(i) + 1:length(S) % 12 -> 943
        % Loop from left/top part of yellow block until right/bottom of
        % yellow block (amount of rows in a yellow block)
        for k=idCountTotal(idCountMap, i) + 1:idCountTotal(idCountMap, i) + idCountMap(i) % 9 -> 11
            % Add scores to array
            imposterCounter = imposterCounter + 1;
            imposterScores(imposterCounter) = S(j,k);
        end
    end
end

disp(imposterCounter);
disp("Finished making imposter scores");
%% Plotting the histograms
disp("Plotting histograms");
numberOfBins = 300;
genuineHist = histogram(genuineScores, numberOfBins);
hold on
imposterHist = histogram(imposterScores, numberOfBins);
hold off
disp("Finished plotting histograms");
%% plotting the perfomance characteristics based on a threshold
threshold = -15;
FMR = sum(imposterScores > threshold)/length(imposterScores);
FNMR = sum(genuineScores < threshold)/length(genuineScores);
DET = [];
bestMatch = 1;
EER = 0;
bestThreshold = 0;
for i=-60:.1:30
    FMR = sum(imposterScores > i)/length(imposterScores);
    FNMR = sum(genuineScores < i)/length(genuineScores);
    possibleEER = abs(FMR - FNMR);
    if possibleEER < bestMatch
        bestMatch = possibleEER;
        EER = FMR;
        bestThreshold = i;
    end
    DET = [DET; [FMR,FNMR]];
end
disp(EER);
disp(bestThreshold);
figure;
plot(DET(:,1),DET(:,2));
title('DET');
xlabel('FMR');
ylabel('FNMR');

figure;
plot(DET(:,1),1-DET(:,2));
title('ROC');
xlabel('FMR');
ylabel('TMR');
%%
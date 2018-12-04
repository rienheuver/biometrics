
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
%%
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
idCountMap(0) = 0;
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

disp('test')

genuineScores = [];
for i=1:length(idCountMap)-1
    for j=1:idCountMap(i)
        for k=1:idCountMap(i)
            if k > j
                genuineScores = [genuineScores, S(j+idCountMap(i-1),k+idCountMap(i-1))];
            end
        end
    end
end


load('FaceData.mat');
p = 56; % image width
q = 46; % image height
d = p*q;
subjectCount = 40;
facesPerSubject = 10;
n = (subjectCount/2) * facesPerSubject; %number of samples for training
l = (subjectCount/2) * facesPerSubject; %number of samples for testing
faceTrain = zeros(d, n); % n*d matrix
faceTest = zeros(d, l); % l%d matrix
Id = zeros(1, l); % l%1 matrix
%%
for i=1:subjectCount/2 % 1 -> 20
    for j=1:facesPerSubject % 1 -> 10
        imageDouble = double(FaceData(i,j).Image)/255;
        faceTrain(:, (i-1)*10+j) = imageDouble(:);
    end
end

for i=(subjectCount/2 + 1):subjectCount % 21 -> 40
    for j=1:facesPerSubject % 1 -> 10
        imageDouble = double(FaceData(i,j).Image)/255;
        faceTest(:, (i-21)*10+j) = imageDouble(:);
        
        % Calculates row number in Id-matrix (1 - 200) from for-loops
        Id(:, (i-21)*10 + j) = i;
    end
end
%%
for i=1:5
    for j=1:10
        %figure, imshow(FaceData(i,j).Image);
    end
end
%%
phi0 = mean(faceTrain,2); %column vector with the mean value for each pixel
faceTrain0 = zeros(d, n);
for i=1:n
    faceTrain0(:, i) = faceTrain(:, i) - phi0; % subtracting to each image the mean vector
end

order_eigen_value = zeros(p*q,1);
covMatrix = 1/(n-1) * faceTrain0 * faceTrain0';
[eig_vec,eig_value] = eig(covMatrix);
diag_eig_value = diag(eig_value);
sum_eig_value = sum(diag_eig_value);
%% Compute the information present in m principal components
v = zeros(d,1);
sum_currently = 0;
m = (1:d)';
for i = 1:d
    sum_currently = sum_currently + diag_eig_value(i);
    v(i) = sum_currently/sum_eig_value;
end
figure();
plot(m,v)
%% Show eigen faces
% Show mean face
figure, imagesc(reshape(phi0, [56,46]));

for m=10:10:100
    phi_m = eig_vec(:,1:m);
    % Show first 10 faces
    for i=1:10
        faceColumn = phi_m(:,i);
        %figure, imagesc(reshape(faceColumn,[56,46]));
    end
    %% Calculate scores
    dissimilarityScores = zeros(l,l);
    matrixA = zeros(m,l);
    for i=1:l
        matrixA(:, i) = phi_m'*(faceTest(:,i)-phi0);
    end

    disSimScore = zeros(l,l);
    for i=1:l
        for j=1:l
            disSimScore(i,j) = norm(matrixA(:,i) - matrixA(:, j));
        end
    end
    %%
     %%Loads score matrix and plots info.
    S = disSimScore;
    [np, nt] = size(S);
    nId = 20;
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
    currentId = 21;
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
    genuineScores = zeros(1, 900);
    genuineCounter = 0;
    for i=1:20 % person 2
        for j=1:10 % 
            for k=1:10 % 
                if k > j
                    genuineCounter = genuineCounter + 1;
                    genuineScores(genuineCounter) = S(j+(i-1)*10,k+(i-1)*10);
                end
            end
        end
    end
    disp("Finished making genuine scores");
    %%
    imposterScores = zeros(1,19000);
    imposterCounter = 0;
    % Loop over persons
    for i=1:20 % 1 -> 20
        % Loop from right part of yellow block until right side of matrix
        for j=i*10+1:length(S) % 11 -> 200
            % Loop from left/top part of yellow block until right/bottom of
            % yellow block (amount of rows in a yellow block)
            for k=(i-1)*10+1:i*10
                % Add scores to array
                imposterCounter = imposterCounter + 1;
                imposterScores(imposterCounter) = S(j,k);
            end
        end
    end
    disp("Finished making imposter scores");
    %% Plotting the histograms
    disp("Plotting histograms");
    numberOfBins = 300;
    %figure();
    %genuineHist = histogram(genuineScores, numberOfBins);
    %hold on
    %imposterHist = histogram(imposterScores, numberOfBins);
    %hold off
    %disp("Finished plotting histograms");
    %% plotting the perfomance characteristics based on a threshold
    FMR = [];
    FNMR = [];
    DET = [];
    bestMatch = 1;
    bestThreshold = 0;
    EER = 0;
    for i=0:.001:10
        FMR_current = sum(imposterScores < i)/length(imposterScores);
        FNMR_current = 1 - (sum(genuineScores < i)/length(genuineScores));
        FMR = [FMR,[i;FMR_current]];
        FNMR = [FNMR,[i; FNMR_current]];
        EER_current = abs(FMR_current - FNMR_current);
        if EER_current < bestMatch
            bestMatch = EER_current;
            EER = FMR_current;
            bestThreshold = i;
        end
        DET = [DET; [FMR_current,FNMR_current]];
    end
    disp("Best threshold: ");
    disp(bestThreshold);
    disp("EER: ");
    disp(EER);
    %plot the ROC
    figure;
    plot(DET(:,1),1-DET(:,2));
    title('ROC');
    xlabel('FMR');
    ylabel('TMR');
end